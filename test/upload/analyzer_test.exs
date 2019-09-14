defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @path "test/fixtures/text.txt"

  test "byte_size" do
    assert {:ok, 9} = Analyzer.byte_size(@path)
  end

  test "checksum" do
    assert {:ok, "qwggwwi4xbzilwzoeksh1g=="} = Analyzer.checksum(@path)
  end
end
