defmodule Upload.ChangesetTest do
  use ExUnit.Case

  alias Upload.Test.Repo
  alias Upload.Test.Person

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(FileStore.Adapters.Test)
    :ok
  end

  test "saves a file" do
    upload = Upload.from_path("test/fixtures/test.txt")
    changeset = Person.changeset(%Person{}, %{avatar: upload})

    assert {:ok, person} = Repo.insert(changeset)
    assert person.avatar.key == "foo"
    assert person.avatar.filename == "bar"
  end
end
