defmodule Upload.StatTest do
  use ExUnit.Case, async: true

  test "the simplest case" do
    path = "test/fixtures/racecar.jpg"

    assert {:ok, stat} = Upload.Stat.stat(path)
    assert stat.size == 1_124_062
    assert stat.content_type == "image/jpeg"
    assert stat.checksum == "ec68c30cd1106f89b3333b16f8c4b425"
  end

  test "an unknown file type" do
    path = "test/fixtures/test.txt"

    assert {:ok, stat} = Upload.Stat.stat(path)
    assert stat.size == 9
    assert stat.content_type == "application/octet-stream"
    assert stat.checksum == "416186c16238c416482d6cce7a4b21d6"
  end

  test "an unknown file type with :content_type option" do
    path = "test/fixtures/test.txt"
    opts = [content_type: "text/plain"]

    assert {:ok, stat} = Upload.Stat.stat(path, opts)
    assert stat.content_type == "text/plain"
  end

  test "an unknown file type with a `nil` :content_type option" do
    path = "test/fixtures/test.txt"
    opts = [content_type: nil]

    assert {:ok, stat} = Upload.Stat.stat(path, opts)
    assert stat.content_type == "application/octet-stream"
  end
end
