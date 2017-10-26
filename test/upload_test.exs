defmodule UploadTest do
  use ExUnit.Case
  doctest Upload, except: [cast: 2, cast_path: 2, get_key: 2]

  @fixture Path.expand("./fixtures/text.txt", __DIR__)
  @plug %Plug.Upload{path: @fixture, filename: "text.txt"}

  test "get_key/1" do
    assert Upload.get_key("phoenix.png") =~ ~r"^[a-z0-9]{32}\.png$"
  end

  test "get_key/2" do
    assert Upload.get_key("phoenix.png", prefix: ["logos"]) =~ ~r"^logos/[a-z0-9]{32}\.png$"
  end

  test "cast/1 with a %Plug.Upload{}" do
    assert {:ok, upload} = Upload.cast(@plug)
    assert upload.path == @plug.path
    assert upload.filename == @plug.filename
    assert upload.key =~ ~r"^[a-z0-9]{32}\.txt$"
    assert upload.status == :pending
  end

  test "cast/1 with an %Upload{}" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert Upload.cast(upload) == upload
  end

  test "cast_path/1" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert upload.path == @plug.path
    assert upload.filename == @plug.filename
    assert upload.key =~ ~r"^[a-z0-9]{32}\.txt$"
    assert upload.status == :pending
  end
end
