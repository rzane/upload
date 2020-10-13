defmodule Upload.BlobTest do
  use Upload.DataCase

  import Ecto.Changeset

  alias Upload.Blob
  alias Upload.Test.Repo

  @path fixture_path("test.txt")
  @upload %Plug.Upload{
    path: @path,
    filename: "test.txt",
    content_type: "text/plain"
  }

  describe "from_path/1" do
    test "builds a changeset" do
      changeset = Blob.from_path(@path)
      assert get_change(changeset, :path)
      assert get_change(changeset, :filename)
      assert get_change(changeset, :content_type)
    end

    test "uploads the file upon insert" do
      changeset = Blob.from_plug(@upload)
      assert {:ok, blob} = Repo.insert(changeset)
      assert blob.key
      assert blob.path
      assert blob.content_type
      assert blob.byte_size
      assert blob.checksum
      assert get_upload_count() == 1
    end
  end

  describe "from_plug/1" do
    test "builds a changeset" do
      changeset = Blob.from_plug(@upload)
      assert get_change(changeset, :path)
      assert get_change(changeset, :filename)
      assert get_change(changeset, :content_type)
    end

    test "uploads the file upon insert" do
      changeset = Blob.from_plug(@upload)
      assert {:ok, blob} = Repo.insert(changeset)
      assert blob.key
      assert blob.path
      assert blob.content_type
      assert blob.byte_size
      assert blob.checksum
      assert get_upload_count() == 1
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

    test "has required fields" do
      changeset = Blob.changeset(%Blob{}, %{})
      assert errors_on(changeset) == @errors
    end

    test "does not insert the file upon insert" do
      changeset = Blob.changeset(%Blob{}, @attributes)
      assert {:ok, _} = Repo.insert(changeset)
      assert get_upload_count() == 0
    end
  end
end
