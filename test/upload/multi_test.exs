defmodule Upload.MultiTest do
  use Upload.DataCase

  alias Upload.Test.Repo
  alias Upload.Test.Person

  @path fixture_path("test.txt")
  @upload %Plug.Upload{path: @path, filename: "test.txt"}

  test "insert/4" do
    changeset = change_person(%{avatar: @upload})
    assert {:ok, %{person: person}} = insert_person(changeset)
    assert person.avatar_id
    assert person.avatar
    assert person.avatar.key in list_uploaded_keys()
  end

  test "insert/4 when avatar is not provided" do
    changeset = change_person(%{})
    assert {:ok, %{person: person}} = insert_person(changeset)
    refute person.avatar_id
  end

  defp insert_person(changeset) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:person, changeset)
    |> Upload.Multi.upload(:person, :avatar)
    |> Repo.transaction()
  end

  defp change_person(attrs) do
    %Person{}
    |> Person.changeset(attrs)
    |> Upload.Changeset.cast_attachment(:avatar)
  end
end
