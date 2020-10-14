defmodule Upload.Analyzer.Video do
  @behaviour Upload.Analyzer

  alias Upload.Utils

  @flags ~w(-print_format json -show_streams -show_format -v error)

  def get_metadata(path) do
    with {:ok, out} <- Utils.cmd(__MODULE__, :ffprobe, @flags ++ [path]),
         {:ok, data} <- Jason.decode(out) do
      {:ok, extract(data)}
    else
      {:error, :enoent} ->
        Utils.log(:warn, "Skipping video analysis because FFmpeg is not installed")
        {:ok, %{}}

      {:error, {:exit, 1}} ->
        Utils.log(:warn, "Skipping video analysis because FFmpeg doesn't support the file")
        {:ok, %{}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def extract(data) do
    format = Map.get(data, "format", %{})
    streams = Map.get(data, "streams", [])
    video = Enum.find(streams, %{}, &video_stream?/1)

    angle = to_integer(get_in(video, ["tags", "angle"]))
    duration = to_float(video["duration"] || format["duration"])
    ratio = to_ratio(video["display_aspect_ratio"])
    width = to_float(video["width"])
    height = compute_height(width, ratio) || to_float(video["height"])
    {width, height} = rotate_dimensions({width, height}, angle)

    %{height: height, width: width, angle: angle, duration: duration, ratio: ratio}
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  def video_stream?(%{"codec_type" => "video"}), do: true
  def video_stream?(_), do: false

  defp rotate_dimensions({height, width}, angle) when angle in [90, 270], do: {width, height}
  defp rotate_dimensions(dimensions, _), do: dimensions

  defp compute_height(nil, _ratio), do: nil
  defp compute_height(_width, nil), do: nil
  defp compute_height(width, [n, d]), do: width * (d / n)

  defp to_integer(nil), do: nil
  defp to_integer(value) when is_integer(value), do: value

  defp to_float(nil), do: nil
  defp to_float(value) when is_float(value), do: value
  defp to_float(value) when is_integer(value), do: value / 1
  defp to_float(value) when is_binary(value), do: String.to_float(value)

  defp to_ratio(nil), do: nil

  defp to_ratio(value) when is_binary(value) do
    value
    |> String.split(":", parts: 2)
    |> Enum.map(&String.to_integer/1)
    |> case do
      [0, _] -> nil
      [n, d] -> [n, d]
      _ -> nil
    end
  end
end
