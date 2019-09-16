defmodule Upload.TransformerTest do
  use ExUnit.Case
  alias Upload.Transformer

  @png_path "test/fixtures/test.png"

  test "apply/2" do
    assert {:ok, path} = Transformer.transform(@png_path, %{"resize" => "50x50"})
    assert File.regular?(path)
    assert get_dimensions(path) == {50, 50}
  end

  defp get_dimensions(path) do
    image = path |> Mogrify.open() |> Mogrify.verbose()
    {image.width, image.height}
  end
end
