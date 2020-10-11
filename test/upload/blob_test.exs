defmodule Upload.BlobTest do
  use Upload.DataCase

  alias Upload.Blob

  @tag :pending
  test "does not attempt to re-upload files"

  @tag :pending
  test "allows inserting without uploading"

  test "from_path/1" do
    path = fixture_path("test.txt")
    changeset = Blob.from_path(path)
    assert get_change(changeset, :path) == path
    assert get_change(changeset, :filename) == "test.txt"
    assert get_change(changeset, :content_type) == "text/plain"
  end

  test "from_plug/1" do
    path = fixture_path("test.txt")
    upload = %Plug.Upload{path: path, filename: "test.txt", content_type: "text/plain"}
    changeset = Blob.from_plug(upload)
    assert get_change(changeset, :path) == path
    assert get_change(changeset, :filename) == "test.txt"
    assert get_change(changeset, :content_type) == "text/plain"
  end

  test "perform_upload/1" do
    path = fixture_path("test.txt")
    changeset = Blob.from_path(path)
    changeset = Blob.perform_upload(changeset)

    assert changeset.valid?
    assert get_change(changeset, :key)
    assert get_change(changeset, :byte_size)
    assert get_change(changeset, :checksum)
    assert get_upload_count() == 1
  end

  test "changeset/2" do
    changeset = Blob.changeset(%Blob{}, %{})
    refute changeset.valid?

    errors = errors_on(changeset)
    assert errors.path == ["can't be blank"]
    assert errors.filename == ["can't be blank"]
  end
end
