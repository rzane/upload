defmodule Upload.MultiTest do
  use Upload.DataCase

  alias Upload.Test.Repo
  alias Upload.Test.Person

  import Ecto.Multi
  import Upload.Multi

  @path "test/fixtures/test.txt"
  @upload %Plug.Upload{path: @path, filename: "test.txt"}

  test "upload/3" do
    changeset = change_person(%{avatar: @upload})
    assert {:ok, %{person: person}} = upload_person(changeset)
    assert person.avatar_id
    assert person.avatar
    assert person.avatar.key in list_uploaded_keys()
  end

  test "upload/3 when avatar is not provided" do
    changeset = change_person(%{})
    assert {:ok, %{person: person}} = upload_person(changeset)
    refute person.avatar_id
  end

  test "purge/3" do
    changeset = change_person(%{avatar: @upload})

    assert {:ok, %{person: person}} = upload_person(changeset)
    assert person.avatar.key in list_uploaded_keys()

    assert {:ok, _} = purge_person(person)
    refute person.avatar.key in list_uploaded_keys()
  end

  defp purge_person(person) do
    new()
    |> delete(:person, person)
    |> purge(:avatar, person.avatar)
    |> Repo.transaction()
  end

  defp upload_person(changeset) do
    new()
    |> insert(:person, changeset)
    |> upload(:avatar, fn ctx -> ctx.person.avatar end)
    |> Repo.transaction()
  end

  defp change_person(attrs) do
    %Person{}
    |> Person.changeset(attrs)
    |> Upload.Changeset.cast_attachment(:avatar)
  end
end
