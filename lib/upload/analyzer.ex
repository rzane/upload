defmodule Upload.Analyzer do
  require Logger

  alias Upload.Analyzer.Image
  alias Upload.Analyzer.Video

  @chunk_size 2_048

  @spec get_byte_size(Path.t()) :: non_neg_integer()
  def get_byte_size(path) do
    path
    |> File.stat!()
    |> Map.fetch!(:size)
  end

  @spec get_checksum(Path.t()) :: binary()
  def get_checksum(path) do
    path
    |> File.stream!([], @chunk_size)
    |> Enum.reduce(:crypto.hash_init(:md5), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  @spec get_metadata(Path.t(), binary() | nil) :: map()
  def get_metadata(path, content_type) do
    case do_get_metadata(path, content_type) do
      {:ok, metadata} ->
        metadata

      {:error, reason} ->
        Logger.warn("Skipping file analysis failed because #{reason}.")
        %{}
    end
  end

  defp do_get_metadata(path, content_type) do
    case content_type do
      "image/" <> _ -> Image.get_metadata(path)
      "video/" <> _ -> Video.get_metadata(path)
      _ -> {:ok, %{}}
    end
  end
end
