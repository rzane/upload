defmodule UploadTest do
  use ExUnit.Case

  alias Upload.Blob
  alias Upload.Test.Repo
  alias Upload.Test.Person
  alias FileStore.Adapters.Test, as: Storage

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(Storage)
    :ok
  end

  describe "uploading a text file" do
    @text %{
      path: "test/fixtures/test.txt",
      filename: "test.txt",
      content_type: "text/plain",
      byte_size: 9,
      checksum: "416186c16238c416482d6cce7a4b21d6",
      metadata: %{}
    }

    test "from a path", do: assert_blob_from_path(@text)
    test "from a %Plug.Upload{}", do: assert_blob_from_plug(@text)
    test "through an association", do: assert_blob_from_assoc(@text)
  end

  describe "uploading an image" do
    @image %{
      path: "test/fixtures/test.png",
      filename: "test.png",
      content_type: "image/png",
      byte_size: 3974,
      checksum: "7330f574cc4eeba3c3036717c560ca9b",
      metadata: %{height: 600, width: 600}
    }

    test "from a path", do: assert_blob_from_path(@image)
    test "from a %Plug.Upload{}", do: assert_blob_from_plug(@image)
    test "through an association", do: assert_blob_from_plug(@image)
  end

  describe "uploading a video" do
    @video %{
      path: "test/fixtures/test.mp4",
      filename: "test.mp4",
      content_type: "video/mp4",
      byte_size: 1_053_651,
      checksum: "59b8487da4236b3d42890fedab86ac64",
      metadata: %{display_aspect_ratio: [4, 3], duration: 13.666667, height: 240.0, width: 320.0}
    }

    test "from a path", do: assert_blob_from_path(@video)
    test "from a %Plug.Upload{}", do: assert_blob_from_plug(@video)
    test "through an association", do: assert_blob_from_plug(@video)
  end

  defp assert_blob_from_path(expected) do
    expected.path
    |> Blob.from_path()
    |> Repo.insert!()
    |> assert_blob(expected)
  end

  defp assert_blob_from_plug(expected) do
    expected
    |> build_plug_upload()
    |> Blob.from_plug()
    |> Repo.insert!()
    |> assert_blob(expected)
  end

  defp assert_blob_from_assoc(expected) do
    %Person{}
    |> Person.changeset(%{avatar: build_plug_upload(expected)})
    |> Repo.insert!()
    |> Map.fetch!(:avatar)
    |> assert_blob(expected)
  end

  defp assert_blob(%Blob{} = blob, expected) do
    assert blob.id
    assert blob.key =~ ~r/^[a-z0-9]{28}$/
    assert blob.key in Storage.list_keys()
    assert blob.filename == expected.filename
    assert blob.content_type == expected.content_type
    assert blob.byte_size == expected.byte_size
    assert blob.checksum == expected.checksum
    assert blob.metadata == expected.metadata
  end

  defp build_plug_upload(expected) do
    %Plug.Upload{
      path: expected.path,
      filename: expected.filename,
      content_type: expected.content_type
    }
  end
end
