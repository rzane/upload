defmodule Upload.Variant do
  # TODO: Return better errors

  alias Upload.Blob
  alias Upload.Key
  alias Upload.Config
  alias Upload.Transformer

  @enforce_keys [:blob, :transforms, :variation_key, :key]
  defstruct [:blob, :transforms, :variation_key, :key]

  @type t() :: %__MODULE__{
          blob: Blob.t(),
          key: binary(),
          transforms: map(),
          variation_key: binary()
        }

  @spec new(Blob.t(), map()) :: t()
  def new(%Blob{} = blob, transforms) do
    variation_key = Key.sign(transforms, :variation)
    key = Key.generate_variant(blob.key, variation_key)

    %__MODULE__{
      blob: blob,
      key: key,
      transforms: transforms,
      variation_key: variation_key
    }
  end

  @spec decode(Blob.t(), binary()) :: {:ok, t()} | {:error, atom() | Keyword.t()}
  def decode(%Blob{} = blob, variation_key) when is_binary(variation_key) do
    with {:ok, transforms} <- Key.verify(variation_key, :variation) do
      key = Key.generate_variant(blob.key, variation_key)

      variant = %__MODULE__{
        blob: blob,
        key: key,
        transforms: transforms,
        variation_key: variation_key
      }

      {:ok, variant}
    end
  end

  @spec process(t()) :: {:ok, t()} | {:error, any()}
  def process(%__MODULE__{blob: blob} = variant) do
    if variant_exists?(variant) do
      {:ok, variant}
    else
      with {:ok, blob_path} <- download_blob(blob),
           {:ok, variant_path} <- transform_variant(variant, blob_path),
           :ok <- delete_file_from_disk(blob_path),
           :ok <- upload_variant(variant, variant_path),
           :ok <- delete_file_from_disk(variant_path),
           do: {:ok, variant}
    end
  end

  defp upload_variant(%__MODULE__{key: key}, path) do
    Config.file_store()
    |> FileStore.upload(path, key)
    |> case do
      :ok -> :ok
      :error -> {:error, :upload_failed}
    end
  end

  defp transform_variant(%__MODULE__{transforms: transforms}, blob_path) do
    with {:ok, variant_path} <- Plug.Upload.random_file("upload"),
         :ok <- Transformer.transform(blob_path, variant_path, transforms) do
      {:ok, variant_path}
    else
      _error -> {:error, :transform_failed}
    end
  end

  defp download_blob(%Blob{} = blob) do
    with {:ok, blob_path} = Plug.Upload.random_file("upload"),
         :ok <- FileStore.download(Config.file_store(), blob.key, blob_path) do
      {:ok, blob_path}
    else
      _error -> {:error, :download_failed}
    end
  end

  defp delete_file_from_disk(file) do
    case File.rm(file) do
      :ok -> :ok
      {:error, reason} -> {:error, :remove_file, reason}
    end
  end

  # TODO: Implement
  defp variant_exists?(_variant) do
    false
  end
end
