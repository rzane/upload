defmodule Upload.Variant do
  # TODO: Return better errors

  alias Upload.Blob
  alias Upload.Key
  alias Upload.Config
  alias Upload.Transformer

  defstruct [:blob, :transforms, :key]

  @type t() :: %__MODULE__{
          blob: Blob.t(),
          transforms: map(),
          key: binary()
        }

  @spec decode(Blob.t(), binary()) :: {:ok, t()} | {:error, atom() | Keyword.t()}
  def decode(%Blob{} = blob, variation) when is_binary(variation) do
    with {:ok, transforms} <- Key.verify(variation, :variation) do
      variant = %__MODULE__{
        blob: blob,
        transforms: transforms,
        key: Key.generate_variant(blob.key, variation)
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
           :ok <- remove_file_from_disk(blob_path),
           :ok <- upload_variant(variant, variant_path),
           :ok <- remove_file_from_disk(variant_path),
           do: {:ok, variant}
    end
  end

  defp upload_variant(%__MODULE__{key: key}, path) do
    Config.file_store()
    |> FileStore.copy(path, key)
    |> case do
      :ok -> :ok
      :error -> {:error, :upload_failed}
    end
  end

  defp transform_variant(%__MODULE__{transforms: transforms}, path) do
    case Transformer.transform(path, transforms) do
      {:ok, variant_path} ->
        {:ok, variant_path}

      _ ->
        {:error, :transform_failed}
    end
  end

  defp download_blob(%Blob{path: path}) when is_binary(path) do
    {:ok, path}
  end

  # TODO: Implement
  defp download_blob(%Blob{}) do
    raise "TODO: Implement blob downloads."
  end

  # TODO: Implement
  defp variant_exists?(_variant) do
    false
  end

  # TODO: Implement
  defp remove_file_from_disk(_path) do
    :ok
  end
end
