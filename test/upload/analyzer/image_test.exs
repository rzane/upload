defmodule Upload.Analyzer.ImageTest do
  use ExUnit.Case
  alias Upload.Analyzer.Image

  @png_path "test/fixtures/test.png"
  @metadata %{height: 600, width: 600}

  test "get_metadata/1" do
    assert Image.get_metadata(@png_path) == {:ok, @metadata}
  end
end
