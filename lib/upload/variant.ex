defmodule Upload.Variant do
  alias Upload.Blob
  alias Upload.Storage
  alias Upload.Transformer
  alias Upload.Verifier
  alias Upload.Utils

  @enforce_keys [:key, :blob, :transforms]
  defstruct [:key, :blob, :transforms]

  @type transforms :: keyword()
  @type t :: %__MODULE__{
          key: binary(),
          blob: Blob.t(),
          transforms: transforms()
        }

  @spec new(Blob.t(), transforms()) :: t()
  def new(%Blob{} = blob, transforms) do
    %__MODULE__{
      blob: blob,
      transforms: transforms,
      key: produce_key(blob, transforms)
    }
  end

  @spec process(t()) :: :ok | {:error, term()}
  def process(%__MODULE__{} = variant) do
    with :error <- stat(variant.key),
         {:ok, blob_path} <- tempfile(),
         :ok <- download(variant.blob_key, blob_path),
         {:ok, variant_path} <- tempfile(),
         :ok <- transform(blob_path, variant_path, variant.transforms),
         :ok <- cleanup(blob_path),
         :ok <- upload(variant_path, variant.key),
         :ok <- cleanup(variant_path),
         do: :ok
  end

  defp stat(key) do
    case Storage.stat(key) do
      {:ok, _} ->
        Utils.debug("Check if file exists at key: #{key} (yes)")
        :ok

      {:error, _} ->
        Utils.debug("Check if file exists at key: #{key} (no)")
        :error
    end
  end

  defp download(key, dest) do
    case Storage.download(key, dest) do
      :ok ->
        Utils.info("Downloaded file from key: #{key}")
        :ok

      {:error, reason} ->
        Utils.error("Failed to download file from key: #{key}")
        {:error, {:download, reason}}
    end
  end

  defp transform(source, dest, transforms) do
    case Transformer.transform(source, dest, transforms) do
      :ok -> :ok
      {:error, reason} -> {:error, {:transform, reason}}
    end
  end

  defp upload(path, key) do
    case Storage.upload(path, key) do
      :ok ->
        Utils.info("Uploaded file to key: #{key}")
        :ok

      {:error, reason} ->
        Utils.info("Failed to upload file to key: #{key}")
        {:error, {:upload, reason}}
    end
  end

  defp cleanup(file) do
    case File.rm(file) do
      :ok -> :ok
      {:error, reason} -> {:error, {:cleanup, reason}}
    end
  end

  defp tempfile do
    case Plug.Upload.random_file("upload") do
      {:ok, tmp} -> {:ok, tmp}
      {reason, _, _} -> {:error, {:tempfile, reason}}
      {reason, _} -> {:error, {:tempfile, reason}}
    end
  end

  defp produce_key(blob, transforms) do
    signed_transforms = Verifier.sign_transforms(transforms)
    "variants/#{blob.key}/#{hexdigest(signed_transforms)}"
  end

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end
end
