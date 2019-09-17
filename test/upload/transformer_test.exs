defmodule Upload.TransformerTest do
  use ExUnit.Case
  alias Upload.Transformer

  @png_path "test/fixtures/test.png"

  test "transform/2" do
    assert {:ok, dest} = Plug.Upload.random_file("upload")
    assert :ok = Transformer.transform(@png_path, dest, %{"resize" => "50x50"})
    assert File.regular?(dest)
    assert get_dimensions(dest) == {50, 50}
  end

  defp get_dimensions(path) do
    image = path |> Mogrify.open() |> Mogrify.verbose()
    {image.width, image.height}
  end
end
