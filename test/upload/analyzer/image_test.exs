defmodule Upload.Analyzer.ImageTest do
  use ExUnit.Case
  alias Upload.Analyzer.Image

  setup do: configure([])

  test "analyzing a JPEG image" do
    path = fixture_path("racecar.jpg")
    assert {:ok, metadata} = Image.analyze(path)
    assert metadata == %{width: 4104, height: 2736}
  end

  test "analyzing a rotated JPEG image" do
    path = fixture_path("racecar_rotated.jpg")
    assert {:ok, metadata} = Image.analyze(path)
    assert metadata == %{width: 2736, height: 4104}
  end

  test "analyzing an SVG image without an XML declaration" do
    path = fixture_path("icon.svg")
    assert {:ok, metadata} = Image.analyze(path)
    assert metadata == %{width: 792, height: 584}
  end

  test "analyzing an unsupported image type" do
    path = fixture_path("test.txt")
    assert {:ok, %{}} = Image.analyze(path)
  end

  test "analyzing when ImageMagick is not installed" do
    configure(identify: [cmd: "command-does-not-exist"])

    path = fixture_path("racecar.jpg")
    assert {:ok, %{}} = Image.analyze(path)
  end

  defp configure(opts) do
    Application.put_env(:upload, Upload.Analyzer.Image, opts)
  end

  defp fixture_path(name) do
    "../../fixtures"
    |> Path.expand(__DIR__)
    |> Path.join(name)
  end
end
