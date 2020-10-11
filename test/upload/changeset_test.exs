defmodule Upload.ChangesetTest do
  use Upload.DataCase

  alias Upload.Blob
  alias Upload.Test.Person

  describe "cast_upload/2" do
    test "accepts a %Plug.Upload{}" do
      upload = %Plug.Upload{
        path: fixture_path("test.txt"),
        filename: "test.txt",
        content_type: "text/plain"
      }

      changeset = change_person(upload)
      assert changeset.valid?
      assert get_change(changeset, :avatar)
    end

    test "accepts a changeset" do
      path = fixture_path("test.txt")
      blob_changeset = Blob.from_path(path)
      changeset = change_person(blob_changeset)
      assert changeset.valid?
      assert get_change(changeset, :avatar)
    end

    test "rejects other values" do
      changeset = change_person(500)
      refute changeset.valid?
    end

    @tag :pending
    test "handles nil values"
  end

  defp change_person(value) do
    %Person{}
    |> Person.changeset(%{"avatar" => value})
    |> Upload.Changeset.cast_upload(:avatar)
  end
end
