defmodule Upload.Analyzer do
  @chunk_size 2_048

  @spec analyze(Upload.t()) :: {:ok, Upload.t()} | {:error, File.posix()}
  def analyze(%Upload{} = upload) do
    with {:ok, byte_size} <- get_byte_size(upload.path),
         {:ok, checksum} <- get_checksum(upload.path) do
      {:ok, %Upload{upload | byte_size: byte_size, checksum: checksum}}
    end
  end

  defp get_byte_size(path) do
    with {:ok, %File.Stat{size: size}} <- File.stat(path) do
      {:ok, size}
    end
  end

  defp get_checksum(path) do
    stream = File.stream!(path, [], @chunk_size)
    {:ok, hash_stream(stream)}
  rescue
    error in File.Error ->
      {:error, error.reason}
  end

  defp hash_stream(stream) do
    stream
    |> Enum.reduce(:crypto.hash_init(:md5), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode64()
    |> String.downcase()
  end
end
