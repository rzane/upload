defmodule Upload.Analyzer.Image do
  @behaviour Upload.Analyzer

  alias Upload.Utils

  @flags ~w(-format %w|%h|%[orientation])
  @rotated ~w(RightTop LeftBottom)

  @impl true
  def get_metadata(path) do
    case Utils.cmd(:identify, @flags ++ [path]) do
      {:ok, out} ->
        {:ok, parse(out)}

      {:error, :enoent} ->
        Utils.warn("Skipping image analysis because ImageMagick is not installed")
        {:ok, %{}}

      {:error, {:exit, 1}} ->
        Utils.warn("Skipping image analysis because ImageMagick doesn't support the file")
        {:ok, %{}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse(out) do
    out
    |> String.trim()
    |> String.split("|")
    |> rotate()
    |> Enum.map(&String.to_integer/1)
    |> rzip([:width, :height])
    |> Enum.into(%{})
  end

  defp rzip(a, b), do: Enum.zip(b, a)
  defp rotate([w, h, o]) when o in @rotated, do: [h, w]
  defp rotate([w, h, _]), do: [w, h]
end
