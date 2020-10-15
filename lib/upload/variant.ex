defmodule Upload.Variant do
  alias Upload.Token
  alias Upload.Storage
  alias Upload.Transformer
  alias Upload.Utils

  def generate_key(blob_key, transforms) do
    transform_key = Token.sign(transforms, :variant)
    "variants/#{blob_key}/#{hexdigest(transform_key)}"
  end

  def process(blob_key, transforms) do
    variant_key = generate_key(blob_key, transforms)

    with :error <- stat(variant_key),
         {:ok, blob_path} <- tempfile(),
         :ok <- download(blob_key, blob_path),
         {:ok, variant_path} <- tempfile(),
         :ok <- transform(blob_path, variant_path, transforms),
         :ok <- cleanup(blob_path),
         :ok <- upload(variant_path, variant_key),
         :ok <- cleanup(variant_path),
         do: {:ok, variant_key}
  end

  defp stat(key) do
    case Storage.stat(key) do
      {:ok, _} ->
        Utils.log(:debug, "Check if file exists at key: #{key} (yes)")
        {:ok, key}

      {:error, _} ->
        Utils.log(:debug, "Check if file exists at key: #{key} (no)")
        :error
    end
  end

  defp download(key, dest) do
    case Storage.download(key, dest) do
      :ok ->
        Utils.log(:info, "Downloaded file from key: #{key}")
        :ok

      {:error, reason} ->
        Utils.log(:error, "Failed to download file from key: #{key}")
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

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end
end
