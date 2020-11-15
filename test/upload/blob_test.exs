defmodule Upload.BlobTest do
  use Upload.DataCase, async: true
  alias Upload.Blob

  @attributes %{
    path: "test/fixtures/test.txt",
    key: "abcdef",
    filename: "text.txt",
    content_type: "text/plain",
    byte_size: 9,
    checksum: "blah"
  }

  @errors %{
    byte_size: ["can't be blank"],
    checksum: ["can't be blank"],
    filename: ["can't be blank"],
    content_type: ["can't be blank"]
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

  test "generates a key" do
    changeset = Blob.changeset(%Blob{}, %{})
    assert changeset.changes.key
  end

  test "does not generate a key when explicitly provided" do
    key = "abc"
    changeset = Blob.changeset(%Blob{}, %{key: key})
    assert changeset.changes.key == key
  end

  test "does not generate a key for an existing record" do
    key = "abc"
    changeset = Blob.changeset(%Blob{key: key}, %{})
    assert changeset.changes == %{}
    assert changeset.data.key == key
  end
end
