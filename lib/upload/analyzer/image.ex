defmodule Upload.Analyzer.Image do
  @behaviour Upload.Analyzer

  alias Upload.Utils

  @flags ~w(-format width:%w|height:%h)

  @impl true
  def get_metadata(path) do
    case Utils.cmd(__MODULE__, :identify, @flags ++ [path]) do
      {:ok, out} ->
        {:ok, parse(out)}

      {:error, :enoent} ->
        Utils.log(:warn, "Skipping image analysis because ImageMagick is not installed")
        {:ok, %{}}

      {:error, {:exit, 1}} ->
        Utils.log(:warn, "Skipping image analysis because ImageMagick doesn't support the file")
        {:ok, %{}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse(out), do: out |> String.split("|") |> Enum.reduce(%{}, &parse/2)
  defp parse("width:" <> width, acc), do: Map.put(acc, :width, String.to_integer(width))
  defp parse("height:" <> height, acc), do: Map.put(acc, :height, String.to_integer(height))
end
