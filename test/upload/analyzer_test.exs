defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @text_path "test/fixtures/test.txt"
  @png_path "test/fixtures/test.png"
  @mp4_path "test/fixtures/test.mp4"

  @text_checksum "416186c16238c416482d6cce7a4b21d6"

  test "get_byte_size/1" do
    assert Analyzer.get_byte_size(@text_path) == 9
  end

  test "get_checksum/1" do
    assert Analyzer.get_checksum(@text_path) == @text_checksum
  end

  test "get_metadata/2 with a text file" do
    assert Analyzer.get_metadata(@text_path, "text/plain") == %{}
  end

  test "get_metadata/2 with a png" do
    assert Analyzer.get_metadata(@png_path, "image/png") == %{height: 600, width: 600}
  end

  test "get_metadata/2 with a video" do
    assert Analyzer.get_metadata(@mp4_path, "video/mp4") == %{
             height: 240,
             width: 320,
             duration: 13.666667,
             display_aspect_ratio: [4, 3]
           }
  end
end
