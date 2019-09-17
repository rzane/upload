defmodule Upload.Variant do
  alias Upload.Key
  alias Upload.Config
  alias Upload.Transformer

  @enforce_keys [:blob_key, :transforms, :variation_key, :key]
  defstruct [:blob_key, :transforms, :variation_key, :key]

  @type t() :: %__MODULE__{
          key: binary(),
          blob_key: Key.t(),
          variation_key: Key.t(),
          transforms: map(),
        }

  @type process_error_reason() ::
          {:cleanup, File.posix()}
          | {:download, term()}
          | {:transform, term()}
          | {:upload, term()}
          | {:tempfile, :no_tmp | :too_many_attempts}

  @spec new(Key.t(), map()) :: t()
  def new(blob_key, transforms) do
    variation_key = Key.sign(transforms, :variation)
    key = Key.generate_variant(blob_key, variation_key)

    %__MODULE__{
      key: key,
      blob_key: blob_key,
      transforms: transforms,
      variation_key: variation_key
    }
  end

  @spec decode(Key.t(), Key.t()) :: {:ok, t()} | {:error, atom() | Keyword.t()}
  def decode(blob_key, variation_key) do
    with {:ok, transforms} <- Key.verify(variation_key, :variation) do
      key = Key.generate_variant(blob.key, variation_key)

      variant = %__MODULE__{
        key: key,
        blob_key: blob_key,
        variation_key: variation_key,
        transforms: transforms
      }

      {:ok, variant}
    end
  end

  @spec process(t()) :: {:ok, t()} | {:error, process_error_reason()}
  def process(%__MODULE__{blob_key: blob_key} = variant) do
    with {:error, _} <- stat(variant),
         {:ok, blob_path} <- tempfile(),
         :ok <- download(blob_key, blob_path),
         {:ok, variant_path} <- tempfile(),
         :ok <- transform(blob_path, variant_path, variant.transforms),
         :ok <- cleanup(blob_path),
         :ok <- upload(variant_path, variant.key),
         :ok <- cleanup(variant_path),
         do: {:ok, variant}
  end

  defp stat(variant) do
    case FileStore.stat(Config.file_store(), variant.key) do
      {:ok, _} -> {:ok, variant}
      {:error, reason} -> {:error, reason}
    end
  end

  defp download(key, dest) do
    case FileStore.download(Config.file_store(), key, dest) do
      :ok -> :ok
      {:error, reason} -> {:error, {:download, reason}}
    end
  end

  defp transform(source, dest, transforms) do
    case Transformer.transform(source, dest, transforms) do
      :ok -> :ok
      {:error, reason} -> {:error, {:transform, reason}}
    end
  end

  defp upload(path, key) do
    case FileStore.upload(Config.file_store(), path, key) do
      :ok -> :ok
      {:error, reason} -> {:error, {:upload, reason}}
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
end
