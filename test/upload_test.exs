defmodule UploadTest do
  use ExUnit.Case

  @path "/foo/bar.pdf"
  @filename "bar.pdf"
  @content_type "application/pdf"

  @plug_upload %Plug.Upload{
    path: @path,
    filename: @filename,
    content_type: @content_type
  }

  test "from_path/1" do
    upload = Upload.from_path(@path)

    assert is_binary(upload.key)
    assert upload.path == @path
    assert upload.filename == @filename
    assert upload.content_type == @content_type
  end

  test "from_plug/1" do
    upload = Upload.from_plug(@plug_upload)

    assert is_binary(upload.key)
    assert upload.path == @path
    assert upload.filename == @filename
    assert upload.content_type == @content_type
  end
end
