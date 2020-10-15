defmodule Upload.Analyzer.VideoTest do
  use ExUnit.Case
  alias Upload.Analyzer.Video

  setup do: configure([])

  test "analyzing a video" do
    path = fixture_path("video.mp4")
    assert {:ok, metadata} = Video.analyze(path)

    assert metadata == %{
             width: 640.0,
             height: 480.0,
             display_aspect_ratio: [4, 3],
             duration: 5.166648
           }
  end

  test "analyzing a rotated video" do
    path = fixture_path("rotated_video.mp4")
    assert {:ok, metadata} = Video.analyze(path)

    assert metadata == %{
             width: 480.0,
             height: 640.0,
             angle: 90,
             display_aspect_ratio: [4, 3],
             duration: 5.001705
           }
  end

  test "analyzing a video with rectangular samples" do
    path = fixture_path("video_with_rectangular_samples.mp4")
    assert {:ok, metadata} = Video.analyze(path)

    assert metadata == %{
             width: 1280.0,
             height: 720.0,
             display_aspect_ratio: [16, 9],
             duration: 5.229055
           }
  end

  test "analyzing a video with an undefined display aspect ratio" do
    path = fixture_path("video_with_undefined_display_aspect_ratio.mp4")
    assert {:ok, metadata} = Video.analyze(path)
    assert metadata == %{width: 640.0, height: 480.0, duration: 3.409571}
  end

  test "analyzing a video with a container-specified duration" do
    path = fixture_path("video.webm")
    assert {:ok, metadata} = Video.analyze(path)

    assert metadata == %{
             width: 640.0,
             height: 480.0,
             duration: 5.22900,
             display_aspect_ratio: [4, 3]
           }
  end

  test "analyzing a video without a video stream" do
    path = fixture_path("video_without_video_stream.mp4")
    assert {:ok, metadata} = Video.analyze(path)
    assert metadata == %{duration: 1.022000}
  end

  test "analyzing when `ffprobe` is not installed" do
    configure(ffprobe: [cmd: "command-does-not-exist"])

    path = fixture_path("video.mp4")
    assert {:ok, %{}} = Video.analyze(path)
  end

  test "analyzing when when file is not recognizable" do
    path = fixture_path("test.txt")
    assert {:ok, %{}} = Video.analyze(path)
  end

  defp configure(opts) do
    Application.put_env(:upload, Upload.Analyzer.Video, opts)
  end

  defp fixture_path(name) do
    "../../fixtures"
    |> Path.expand(__DIR__)
    |> Path.join(name)
  end
end
