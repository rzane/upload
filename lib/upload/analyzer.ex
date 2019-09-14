defmodule Upload.Analyzer do
  @chunk_size 2_048

  @spec byte_size(Path.t()) :: {:ok, non_neg_integer()} | {:error, File.posix()}
  def byte_size(path) do
    with {:ok, %File.Stat{size: size}} <- File.stat(path) do
      {:ok, size}
    end
  end

  @spec checksum(Path.t()) :: {:ok, binary()} | {:error, File.posix()}
  def checksum(path) do
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
