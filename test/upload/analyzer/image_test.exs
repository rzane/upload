defmodule Upload.Analyzer.ImageTest do
  use ExUnit.Case
  alias Upload.Analyzer.Image

  @png Path.expand("../../fixtures/test.png", __DIR__)
  @txt Path.expand("../../fixtures/test.txt", __DIR__)

  setup do: configure([])

  test "collects image dimensions" do
    assert {:ok, metadata} = Image.get_metadata(@png)
    assert metadata == %{height: 600, width: 600}
  end

  test "fails gracefully when `identify` is not installed" do
    configure(identify: [cmd: "command-does-not-exist"])
    assert {:ok, %{}} = Image.get_metadata(@png)
  end

  test "fails gracefully when file is not recognizable" do
    assert {:ok, %{}} = Image.get_metadata(@txt)
  end

  defp configure(opts) do
    Application.put_env(:upload, Upload.Analyzer.Image, opts)
  end
end
