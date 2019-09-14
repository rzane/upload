defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @path "test/fixtures/test.txt"
  @invalid_path "test/fixtures/does_not_exist.txt"
  @checksum "416186c16238c416482d6cce7a4b21d6"

  test "byte_size/1" do
    assert Analyzer.byte_size(@path) == {:ok, 9}
  end

  test "byte_size/1 with invalid path" do
    assert Analyzer.checksum(@invalid_path) == {:error, :enoent}
  end

  test "checksum/1" do
    assert Analyzer.checksum(@path) == {:ok, @checksum}
  end

  test "checksum/1 with invalid path" do
    assert Analyzer.checksum(@invalid_path) == {:error, :enoent}
  end
end
