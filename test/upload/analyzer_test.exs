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

  test "metadata/1 with a text file" do
    assert Analyzer.metadata(@text_path, "text/plain") == {:ok, %{}}
  end

  test "metadata/ with a png" do
    assert Analyzer.metadata(@png_path, "image/png") == {:ok, %{height: 600, width: 600}}
  end

  test "metadata/ with a video" do
    assert {:ok, analysis} = Analyzer.metadata(@mp4_path, "video/mp4")

    assert analysis == %{
             height: 240,
             width: 320,
             duration: 13.666667,
             display_aspect_ratio: [4, 3]
           }
  end
end
