defmodule Upload.ChangesetTest do
  use ExUnit.Case

  alias Upload.Test.Repo
  alias Upload.Test.Person
  alias FileStore.Adapters.Test, as: Storage

  @path "test/fixtures/test.txt"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(Storage)
    :ok
  end

  test "cast_upload/1 uploads a file and saves it t " do
    upload = Upload.from_path(@path)
    changeset = Person.changeset(%Person{}, %{avatar: upload})

    assert {:ok, person} = Repo.insert(changeset)
    assert person.avatar.id
    assert person.avatar.key
    assert person.avatar.byte_size
    assert person.avatar.checksum
    assert person.avatar.filename == "test.txt"
    assert person.avatar.content_type == "text/plain"
    assert person.avatar.key in Storage.list_keys()
  end
end
