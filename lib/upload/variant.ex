defmodule Upload.Variant do
  alias Upload.Key
  alias Upload.Blob
  alias Upload.Storage
  alias Upload.Transformer

  @enforce_keys [:blob]
  defstruct [:blob, transforms: []]

  @type key :: binary()
  @type transforms :: keyword()
  @type signed_transforms :: binary()
  @type stage :: :download | :upload | :transform | :cleanup
  @type t :: %__MODULE__{blob: Blob.t(), transforms: transforms()}

  @spec new(Blob.t(), transforms) :: t
  def new(%Blob{} = blob, transforms \\ []) do
    %__MODULE__{blob: blob, transforms: transforms}
  end

  @spec transform(t, transforms) :: t
  def transform(variant, transforms) do
    %__MODULE__{variant | transforms: variant.transforms ++ transforms}
  end

  @spec ensure_exists(t) :: {:ok, key} | {:error, {stage, term}}
  def ensure_exists(variant) do
    key = Key.generate(variant)

    case Storage.stat(key) do
      {:ok, _} -> {:ok, key}
      {:error, _} -> do_create(key, variant)
    end
  end

  @spec create(t) :: {:ok, key} | {:error, {stage, term}}
  def create(variant) do
    variant
    |> Key.generate()
    |> do_create(variant)
  end

  defp do_create(key, variant) do
    with {:ok, blob_path} <- tempfile(:download),
         :ok <- download(variant.blob.key, blob_path),
         {:ok, variant_path} <- tempfile(:transform),
         :ok <- transform(blob_path, variant_path, variant.transforms),
         :ok <- cleanup(blob_path),
         :ok <- upload(variant_path, key),
         :ok <- cleanup(variant_path),
         do: {:ok, key}
  end

  defp tempfile(stage) do
    case Plug.Upload.random_file("upload") do
      {:ok, tmp} -> {:ok, tmp}
      {reason, _, _} -> {:error, {stage, reason}}
      {reason, _} -> {:error, {stage, reason}}
    end
  end

  defp transform(source, dest, transforms) do
    source
    |> Transformer.transform(dest, transforms)
    |> tag(:transform)
  end

  defp download(key, dest), do: key |> Storage.download(dest) |> tag(:download)
  defp upload(path, key), do: path |> Storage.upload(key) |> tag(:upload)
  defp cleanup(path), do: path |> File.rm() |> tag(:cleanup)

  defp tag(:ok, _action), do: :ok
  defp tag({:error, reason}, action), do: {:error, {action, reason}}
end
