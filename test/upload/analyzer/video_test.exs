defmodule Upload.Analyzer.VideoTest do
  use ExUnit.Case
  alias Upload.Analyzer.Video

  @mp4 Path.expand("../../fixtures/test.mp4", __DIR__)
  @txt Path.expand("../../fixtures/test.txt", __DIR__)

  setup do: configure([])

  test "collects video metadata" do
    assert {:ok, metadata} = Video.get_metadata(@mp4)
    assert metadata == %{height: 240.0, width: 320.0, duration: 13.666667, ratio: [4, 3]}
  end

  test "fails gracefully when `ffprobe` is not installed" do
    configure(ffprobe: [cmd: "command-does-not-exist"])
    assert {:ok, %{}} = Video.get_metadata(@mp4)
  end

  test "fails gracefully when file is not recognizable" do
    assert {:ok, %{}} = Video.get_metadata(@txt)
  end

  defp configure(opts) do
    Application.put_env(:upload, Upload.Analyzer.Video, opts)
  end
end
