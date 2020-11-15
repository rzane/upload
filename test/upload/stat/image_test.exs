defmodule Upload.Stat.ImageTest do
  use ExUnit.Case

  alias Upload.Stat.Image
  alias Upload.ExitError
  alias Upload.CommandError

  @fixtures %{
    "test/fixtures/image.jpg" => %{
      width: 4104,
      height: 2736
    },
    "test/fixtures/image_rotated.jpg" => %{
      width: 2736,
      height: 4104
    },
    "test/fixtures/image.svg" => %{
      width: 792,
      height: 584
    }
  }

  setup do: configure([])

  for {path, meta} <- @fixtures do
    test path do
      path = unquote(path)
      meta = unquote(Macro.escape(meta))
      mime = MIME.from_path(path)
      assert Image.stat(path, mime) == {:ok, meta}
    end
  end

  test "skips content types that are not supported" do
    assert {:ok, nil} = Image.stat("test/fixtures/test.txt", "text/plain")
  end

  test "errors when the file is not unsupported" do
    assert {:error, %ExitError{}} = Image.stat("test/fixtures/test.txt")
  end

  test "errors when `identify` is not installed" do
    configure(identify: "command-does-not-exist")

    assert {:error, %CommandError{}} = Image.stat("test/fixtures/racecar.jpg")
  end

  defp configure(opts) do
    Application.put_env(:upload, Image, opts)
  end
end
