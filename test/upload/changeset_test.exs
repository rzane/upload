defmodule Upload.ChangesetTest do
  use ExUnit.Case

  alias Upload.Test.Repo
  alias Upload.Test.Person
  alias FileStore.Adapters.Test, as: Storage

  @path "test/fixtures/test.png"
  @filename "test.png"
  @content_type "image/png"
  @metadata %{height: 600, width: 600}
  @plug_upload %Plug.Upload{
    path: @path,
    filename: @filename,
    content_type: @content_type
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(Storage)
    :ok
  end

  test "cast_upload/1 uploads a file and saves it" do
    upload = Upload.Blob.from_path(@path)
    changeset = Person.changeset(%Person{}, %{avatar: upload})

    assert {:ok, person} = Repo.insert(changeset)
    assert person.avatar.id
    assert person.avatar.key
    assert person.avatar.byte_size
    assert person.avatar.checksum
    assert person.avatar.filename == @filename
    assert person.avatar.content_type == @content_type
    assert person.avatar.metadata == @metadata
    assert person.avatar.key in Storage.list_keys()
  end

  test "cast_upload/1 with a %Plug.Upload{}" do
    changeset = Person.changeset(%Person{}, %{avatar: @plug_upload})

    assert {:ok, person} = Repo.insert(changeset)
    assert person.avatar.id
    assert person.avatar.key
    assert person.avatar.byte_size
    assert person.avatar.checksum
    assert person.avatar.filename == @filename
    assert person.avatar.content_type == @content_type
    assert person.avatar.metadata == @metadata
    assert person.avatar.key in Storage.list_keys()
  end
end
