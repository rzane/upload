defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @text_path "test/fixtures/test.txt"
  @png_path "test/fixtures/test.png"
  @mp4_path "test/fixtures/test.mp4"
  @bad_path "test/fixtures/does_not_exist.txt"

  @text_checksum "416186c16238c416482d6cce7a4b21d6"

  test "byte_size/1" do
    assert Analyzer.byte_size(@text_path) == {:ok, 9}
  end

  test "byte_size/1 with invalid path" do
    assert Analyzer.checksum(@bad_path) == {:error, :enoent}
  end

  test "checksum/1" do
    assert Analyzer.checksum(@text_path) == {:ok, @text_checksum}
  end

  test "checksum/1 with invalid path" do
    assert Analyzer.checksum(@bad_path) == {:error, :enoent}
  end

  test "analyze/1 with a text file" do
    assert Analyzer.analyze(@text_path, "text/plain") == {:ok, %{}}
  end

  test "analyze/1 with a png" do
    assert Analyzer.analyze(@png_path, "image/png") == {:ok, %{height: 600, width: 600}}
  end

  test "analyze/1 with a video" do
    assert {:ok, analysis} = Analyzer.analyze(@mp4_path, "video/mp4")

    assert analysis == %{
             height: 240,
             width: 320,
             duration: 13.666667,
             display_aspect_ratio: [4, 3]
           }
  end
end
