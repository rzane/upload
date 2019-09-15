defmodule Upload.Analyzer.Image do
  @moduledoc false

  @spec get_metadata(Path.t()) :: {:ok, map()} | {:error, binary()}
  if Code.ensure_compiled?(Mogrify) do
    def get_metadata(path) do
      image = path |> Mogrify.open() |> Mogrify.verbose()
      {:ok, prune(%{height: image.height, width: image.width})}
    rescue
      error ->
        {:error, "Mogrify failed with error: #{inspect(error)}"}
    end
  else
    def get_metadata(path) do
      {:error, "the Mogrify package is not installed"}
    end
  end

  defp prune(values) do
    values |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Enum.into(%{})
  end
end
