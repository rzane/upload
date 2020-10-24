defmodule Upload.ChangesetTest do
  use Upload.DataCase

  import Ecto.Changeset
  import Upload.Changeset

  alias Upload.Test.Person

  @path fixture_path("test.txt")
  @upload %Plug.Upload{
    path: @path,
    filename: "test.txt",
    content_type: "text/plain"
  }

  describe "cast_attachment/3" do
    test "accepts a Plug.Upload" do
      changeset = change_person(%{avatar: @upload})
      assert changeset.valid?
      assert changeset.changes.avatar
      assert changeset.changes.avatar.action == :insert
      assert changeset.changes.avatar.changes.key
      assert changeset.changes.avatar.changes.path
      assert changeset.changes.avatar.changes.filename
    end

    test "accepts nil" do
      changeset = change_person(%{avatar: nil})
      assert changeset.valid?
      assert changeset.changes.avatar == nil
    end

    test "rejects a path" do
      changeset = change_person(%{avatar: @path})
      refute changeset.valid?
      assert changeset.errors == [{:avatar, {"is invalid", []}}]
    end

    test "rejects invalid values with a custom message" do
      changeset = change_person(%{avatar: 42}, invalid_message: "boom")
      refute changeset.valid?
      assert changeset.errors == [{:avatar, {"boom", []}}]
    end
  end

  describe "validate_blob/3" do
    test "allows validations to be run against the blob's changeset" do
      changeset =
        validate_avatar(%{avatar: @upload}, fn blob_changeset ->
          validate_inclusion(blob_changeset, :content_type, ["image/png"])
        end)

      assert errors_on(changeset.changes.avatar) == %{content_type: ["is invalid"]}
    end
  end

  describe "validate_content_type/4" do
    test "produces errors for invalid content type" do
      changeset =
        %{avatar: @upload}
        |> change_person()
        |> validate_content_type(:avatar, ["image/png"])

      assert errors_on(changeset.changes.avatar) == %{content_type: ["is invalid"]}
    end

    @tag :pending
    test "accepts a custom message"
  end

  describe "validate_byte_size/3" do
    test "produces errors for files that don't match the specified size" do
      changeset =
        %{avatar: @upload}
        |> change_person()
        |> validate_byte_size(:avatar, greater_than: {5, :megabyte})

      assert errors_on(changeset.changes.avatar) == %{
               byte_size: ["must be greater than 5.0e6"]
             }
    end

    @tag :pending
    test "accepts a custom message"
  end

  defp change_person(attrs, opts \\ []) do
    %Person{}
    |> Person.changeset(attrs)
    |> cast_attachment(:avatar, opts)
  end

  defp validate_avatar(attrs, fun) do
    attrs
    |> change_person()
    |> validate_attachment(:avatar, fun)
  end
end
