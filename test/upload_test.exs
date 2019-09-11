defmodule UploadTest do
  use ExUnit.Case

  doctest Upload,
    except: [
      get_url: 1,
      get_signed_url: 2,
      transfer: 1,
      generate_key: 2,
      cast: 2,
      cast_path: 2
    ]

  @fixture Path.expand("./fixtures/text.txt", __DIR__)
  @plug %Plug.Upload{path: @fixture, filename: "text.txt"}

  test "get_url/1 and transfer/1" do
    start_supervised(Upload.Adapters.Test)

    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, upload} = Upload.transfer(upload)

    assert Upload.get_url(upload) == upload.key
    assert Upload.get_url(upload.key) == upload.key
  end

  test "get_signed_url/2" do
    start_supervised(Upload.Adapters.Test)

    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, upload} = Upload.transfer(upload)

    assert Upload.get_signed_url(upload) == {:ok, upload.key}
    assert Upload.get_signed_url(upload.key) == {:ok, upload.key}
  end

  test "generate_key/1" do
    assert Upload.generate_key("phoenix.png") =~ ~r"^[a-z0-9]{32}\.png$"
  end

  test "generate_key/2" do
    assert Upload.generate_key("phoenix.png", prefix: ["logos"]) =~ ~r"^logos/[a-z0-9]{32}\.png$"
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
    assert {:ok, ^upload} = Upload.cast(upload)
  end

  test "cast/1 with something else" do
    assert Upload.cast(100) == :error
    assert Upload.cast(nil) == :error
  end

  test "cast_path/1 with a path" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert upload.path == @plug.path
    assert upload.filename == @plug.filename
    assert upload.key =~ ~r"^[a-z0-9]{32}\.txt$"
    assert upload.status == :pending
  end

  test "cast_path/1 with something else" do
    assert :error = Upload.cast_path(100)
    assert :error = Upload.cast_path(nil)
  end
end
