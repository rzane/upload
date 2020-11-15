defmodule Upload.Variant do
  alias Upload.Key
  alias Upload.Blob
  alias Upload.Storage
  alias Upload.RandomFileError
  alias Upload.Variant.Transformer

  @enforce_keys [:blob]
  defstruct [:blob, transforms: []]

  @type key :: binary()
  @type transforms :: keyword()
  @type signed_transforms :: binary()
  @type t :: %__MODULE__{blob: Blob.t(), transforms: transforms()}

  @type error ::
          %RandomFileError{}
          | %FileStore.UploadError{}
          | %FileStore.DownloadError{}
          | %File.Error{}

  @spec new(Blob.t(), transforms) :: t
  def new(%Blob{} = blob, transforms \\ []) do
    %__MODULE__{blob: blob, transforms: transforms}
  end

  @spec transform(t, transforms) :: t
  def transform(variant, transforms) do
    %__MODULE__{variant | transforms: variant.transforms ++ transforms}
  end

  @spec ensure_exists(t) :: {:ok, key} | {:error, error()}
  def ensure_exists(variant) do
    key = Key.generate(variant)

    case Storage.stat(key) do
      {:ok, _} -> {:ok, key}
      {:error, _} -> do_create(key, variant)
    end
  end

  @spec create(t) :: {:ok, key} | {:error, error()}
  def create(variant) do
    variant
    |> Key.generate()
    |> do_create(variant)
  end

  defp do_create(key, variant) do
    with {:ok, blob_path} <- create_random_file(),
         :ok <- Storage.download(variant.blob.key, blob_path),
         {:ok, variant_path} <- create_random_file(),
         :ok <- transform(blob_path, variant_path, variant.transforms),
         :ok <- cleanup(blob_path),
         :ok <- Storage.upload(variant_path, key),
         :ok <- cleanup(variant_path),
         do: {:ok, key}
  end

  defp create_random_file do
    case Plug.Upload.random_file("upload") do
      {:ok, tmp} -> {:ok, tmp}
      reason -> {:error, %RandomFileError{reason: reason}}
    end
  end

  defp transform(source, dest, transforms) do
    Transformer.transform(source, dest, transforms)
  end

  defp cleanup(path) do
    with {:error, reason} <- File.rm(path) do
      %File.Error{path: path, reason: reason, action: "remove temporary file"}
    end
  end
end
