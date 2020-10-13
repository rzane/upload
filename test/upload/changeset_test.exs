defmodule Upload.ChangesetTest do
  use Upload.DataCase

  alias Upload.Test.Repo
  alias Upload.Test.Person

  test "does nothing when the field is not provided" do
    changeset = change_person(%{})
    assert changeset.valid?
    assert changeset.errors == []
    assert changeset.changes == %{}
  end

  test "attaching a blob to a new record" do
    upload = build_upload("test.txt")
    changeset = change_person(%{avatar: upload})

    assert {:ok, person} = Repo.insert(changeset)
    assert person.avatar_id
    assert person.avatar.key
    assert person.avatar.checksum
    assert person.avatar.byte_size
    assert person.avatar.filename
  end

  test "attaching a blob to an existing record" do
    person = create_person()
    upload = build_upload("test.txt")
    changeset = change_person(person, %{avatar: upload})

    assert {:ok, person} = Repo.update(changeset)
    assert person.avatar_id
    assert person.avatar.key
    assert person.avatar.checksum
    assert person.avatar.byte_size
    assert person.avatar.filename
    assert upload_exists?(person.avatar.key)
  end

  test "removing a blob" do
    upload = build_upload("test.txt")
    person = create_person(%{avatar: upload})
    old_avatar = person.avatar

    changeset = change_person(person, %{avatar: nil})
    assert {:ok, person} = Repo.update(changeset)

    refute person.avatar_id
    refute person.avatar

    refute Repo.reload(old_avatar)
    refute upload_exists?(old_avatar.key)
  end

  test "replacing a blob" do
    upload = build_upload("test.txt")
    person = create_person(%{avatar: upload})
    old_avatar = person.avatar

    changeset = change_person(person, %{avatar: upload})
    assert {:ok, person} = Repo.update(changeset)

    assert person.avatar_id
    assert Repo.reload(person.avatar)
    assert upload_exists?(person.avatar.key)

    refute Repo.reload(old_avatar)
    refute upload_exists?(old_avatar.key)
  end

  defp build_upload(filename) do
    %Plug.Upload{filename: filename, path: fixture_path(filename)}
  end

  defp create_person(attrs \\ %{}) do
    attrs
    |> change_person()
    |> Repo.insert!()
    |> Repo.preload(:avatar)
  end

  defp change_person(person \\ %Person{}, attrs) do
    person
    |> Person.changeset(attrs)
    |> Upload.Changeset.cast_attachment(:avatar)
  end
end
