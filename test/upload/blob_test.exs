defmodule Upload.BlobTest do
  use Upload.DataCase

  alias Upload.Blob

  @path fixture_path("test.txt")
  @upload %Plug.Upload{
    path: @path,
    filename: "test.txt",
    content_type: "text/plain"
  }

  describe "from_path/1" do
    test "builds a changeset" do
      changeset = Blob.from_path(@path)
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
    end
  end

  describe "from_plug/1" do
    test "builds a changeset" do
      changeset = Blob.from_plug(@upload)
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
    end
  end

  describe "changeset/2" do
    @attributes %{
      path: @path,
      key: "abcdef",
      filename: "text.txt",
      content_type: "text/plain",
      byte_size: 9,
      checksum: "blah"
    }

    @errors %{
      key: ["can't be blank"],
      byte_size: ["can't be blank"],
      checksum: ["can't be blank"],
      filename: ["can't be blank"]
    }

    test "is valid with required attributes" do
      changeset = Blob.changeset(%Blob{}, @attributes)
      assert changeset.valid?
      assert changeset.errors == []
    end

    test "is invalid when missing required attributes" do
      changeset = Blob.changeset(%Blob{}, %{})
      assert errors_on(changeset) == @errors
    end
  end
end
