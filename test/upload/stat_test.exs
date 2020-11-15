defmodule Upload.StatTest do
  use ExUnit.Case, async: true

  alias Upload.Stat

  @fixtures %{
    "test/fixtures/image.jpg" => %Stat{
      byte_size: 1_124_062,
      filename: "image.jpg",
      content_type: "image/jpeg",
      path: "test/fixtures/image.jpg",
      checksum: "ec68c30cd1106f89b3333b16f8c4b425"
    },
    "test/fixtures/test.txt" => %Stat{
      byte_size: 9,
      filename: "test.txt",
      content_type: "text/plain",
      path: "test/fixtures/image.jpg",
      checksum: "416186c16238c416482d6cce7a4b21d6"
    }
  }

  for {path, stat} <- @fixtures do
    test path do
      path = unquote(path)
      stat = unquote(Macro.escape(stat))
      assert Stat.stat(path) == {:ok, stat}
    end
  end
end
