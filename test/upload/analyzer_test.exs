defmodule Upload.AnalyzerTest do
  use ExUnit.Case
  alias Upload.Analyzer

  @path "test/fixtures/test.txt"

  test "analyze/1" do
    upload = Upload.from_path(@path)

    assert {:ok, upload} = Analyzer.analyze(upload)
    assert upload.byte_size == 9
    assert upload.checksum == "qwggwwi4xbzilwzoeksh1g=="
  end
end
