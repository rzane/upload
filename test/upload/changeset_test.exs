defmodule Upload.ChangesetTest do
  use Upload.DataCase
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

  describe "validate_attachment_type/4" do
    @tag :pending
    test "allow"

    @tag :pending
    test "forbid"

    @tag :pending
    test "accepts a custom message"
  end

  describe "validate_attachment_size/3" do
    @tag :pending
    test "less than"

    @tag :pending
    test "greater than"

    @tag :pending
    test "accepts a custom message"
  end

  defp change_person(attrs, opts \\ []) do
    %Person{}
    |> Person.changeset(attrs)
    |> cast_attachment(:avatar, opts)
  end
end
