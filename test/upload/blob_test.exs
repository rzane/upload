defmodule Upload.BlobTest do
  use Upload.DataCase, async: true
  alias Upload.Blob

  @path "test/fixtures/test.txt"
  @upload %Plug.Upload{path: @path, filename: "racecar.jpg"}

  describe "from_path/1" do
    test "builds a changeset" do
      changeset = Blob.from_path(@path)
      assert changeset.changes.key
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
      assert changeset.changes.byte_size
      assert changeset.changes.checksum
    end
  end

  describe "from_plug/1" do
    test "builds a changeset" do
      changeset = Blob.from_plug(@upload)
      assert changeset.changes.key
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
      assert changeset.changes.byte_size
      assert changeset.changes.checksum
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
