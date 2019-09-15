defmodule Upload.Analyzer.Image do
  @moduledoc false

  @spec get_metadata(Path.t()) :: {:ok, map()} | :error
  def get_metadata(path) do
    image = path |> Mogrify.open() |> Mogrify.verbose()
    {:ok, prune(%{height: image.height, width: image.width})}
  end

  defp prune(values) do
    values |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Enum.into(%{})
  end
end
