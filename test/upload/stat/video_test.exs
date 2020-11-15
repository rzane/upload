defmodule Upload.Stat.VideoTest do
  use ExUnit.Case

  alias Upload.Stat.Video
  alias Upload.ExitError
  alias Upload.CommandError

  @fixtures %{
    "test/fixtures/video.mp4" => %{
      width: 640.0,
      height: 480.0,
      display_aspect_ratio: [4, 3],
      duration: 5.166648
    },
    "test/fixtures/video_rotated.mp4" => %{
      width: 480.0,
      height: 640.0,
      angle: 90,
      display_aspect_ratio: [4, 3],
      duration: 5.001705
    },
    "test/fixtures/video_with_rectangular_samples.mp4" => %{
      width: 1280.0,
      height: 720.0,
      display_aspect_ratio: [16, 9],
      duration: 5.229055
    },
    "test/fixtures/video_with_undefined_display_aspect_ratio.mp4" => %{
      width: 640.0,
      height: 480.0,
      duration: 3.409571
    },
    "test/fixtures/video_with_container_specified_duration.webm" => %{
      width: 640.0,
      height: 480.0,
      duration: 5.22900,
      display_aspect_ratio: [4, 3]
    },
    "test/fixtures/video_without_video_stream.mp4" => %{
      duration: 1.022000
    }
  }

  setup do: configure([])

  for {path, meta} <- @fixtures do
    test Path.basename(path) do
      path = unquote(path)
      meta = unquote(Macro.escape(meta))
      mime = MIME.from_path(path)
      assert Video.stat(path, mime) == {:ok, meta}
    end
  end

  test "skips content types that are not supported" do
    assert {:ok, nil} = Video.stat("test/fixtures/test.txt", "text/plain")
  end

  test "errors when when file is not recognized" do
    assert {:error, %ExitError{}} = Video.stat("test/fixtures/test.txt")
  end

  test "errors when `ffprobe` is not installed" do
    configure(ffprobe: "command-does-not-exist")

    assert {:error, %CommandError{}} = Video.stat("test/fixtures/video.mp4")
  end

  defp configure(opts) do
    Application.put_env(:upload, Video, opts)
  end
end
