defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @path "test/fixtures/test.txt"
  @invalid_path "test/fixtures/does_not_exist.txt"

  test "byte_size/1" do
    assert Analyzer.byte_size(@path) == {:ok, 9}
  end

  test "byte_size/1 with invalid path" do
    assert Analyzer.checksum(@invalid_path) == {:error, :enoent}
  end

  test "checksum/1" do
    assert Analyzer.checksum(@path) == {:ok, "qwggwwi4xbzilwzoeksh1g=="}
  end

  test "checksum/1 with invalid path" do
    assert Analyzer.checksum(@invalid_path) == {:error, :enoent}
  end
end
