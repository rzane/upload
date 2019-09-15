defmodule Upload.Analyzer.VideoTest do
  use ExUnit.Case
  alias Upload.Analyzer.Video

  @mp4_path "test/fixtures/test.mp4"
  @metadata %{
    height: 240,
    width: 320,
    duration: 13.666667,
    display_aspect_ratio: [4, 3]
  }

  setup do
    Application.delete_env(:upload, Video)
  end

  test "get_metadata/1" do
    assert Video.get_metadata(@mp4_path) == {:ok, @metadata}
  end

  test "get_metadata/1 when ffprobe is not installed" do
    Application.put_env(:upload, Video, ffprobe: "script-does-not-exist")
    assert Video.get_metadata(@mp4_path) == {:error, "ffprobe does not appear to be installed"}
  end

  test "get_metadata/1 when ffprobe fails" do
    Application.put_env(:upload, Video, ffprobe: "false")

    assert Video.get_metadata(@mp4_path) ==
             {:error, "ffprobe produced a non-zero exit code (code: 1)"}
  end
end
