defmodule Upload.BlobTest do
  use Upload.DataCase

  alias Upload.Blob
  alias Upload.Test.Repo

  @path fixture_path("test.txt")
  @upload %Plug.Upload{
    path: @path,
    filename: "test.txt",
    content_type: "text/plain"
  }

  describe "generate_key/0" do
    test "generates 28-character, base36-encoded key" do
      for _ <- 0..10 do
        assert Blob.generate_key() =~ ~r/^[a-z0-9]{28}$/
      end
    end
  end

  describe "from_path/1" do
    test "builds a changeset" do
      changeset = Blob.from_path(@path)
      assert changeset.changes.key
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
    end

    test "collects file information before being saved" do
      changeset = Blob.from_path(@path)
      blob = Repo.insert!(changeset)
      assert blob.byte_size
      assert blob.checksum
    end
  end

  describe "from_plug/1" do
    test "builds a changeset" do
      changeset = Blob.from_plug(@upload)
      assert changeset.changes.key
      assert changeset.changes.path
      assert changeset.changes.filename
      assert changeset.changes.content_type
    end

    test "collects file information before being saved" do
      changeset = Blob.from_plug(@upload)
      blob = Repo.insert!(changeset)
      assert blob.byte_size
      assert blob.checksum
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
