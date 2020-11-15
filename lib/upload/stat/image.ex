defmodule Upload.Stat.Image do
  @behaviour Upload.Stat

  @flags ~w(-format %w|%h|%[orientation])
  @rotated ~w(RightTop LeftBottom)

  @impl true
  def stat(path, "image/" <> _), do: stat(path)
  def stat(_path, _content_type), do: {:ok, nil}

  @doc false
  def stat(path) do
    with {:ok, out} <- identify(@flags ++ [path]) do
      {:ok, parse(out)}
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

  defp identify(args) do
    :upload
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:identify, "identify")
    |> Upload.Utils.cmd(args)
  end
end
