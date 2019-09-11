defmodule Upload.Adapters.GCSTest do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.GCS

  alias Upload.Adapters.GCS, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  @project System.get_env("GCS_PROJECT") || "whatever"
  @bucket Adapter.bucket()

  setup_all do
    {:ok, conn} = Adapter.build_connection()

    {:ok, _} =
      GoogleApi.Storage.V1.Api.Buckets.storage_buckets_insert(
        conn,
        @project,
        body: %{name: @bucket}
      )

    {:ok, conn: conn}
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "https://storage.googleapis.com/my_bucket_name/foo.txt"

    assert Adapter.get_url("foo/bar.txt") ==
             "https://storage.googleapis.com/my_bucket_name/foo/bar.txt"
  end

  test "get_signed_url/2" do
    assert {:ok, url} = Adapter.get_signed_url("foo.txt", [])
    query = url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()
    assert query["Expires"] == "3600"
    assert query["GoogleAccessId"]
    assert query["Signature"]
  end

  test "get_signed_url/2 with a custom expiration" do
    assert {:ok, url} = Adapter.get_signed_url("foo.txt", expires_in: 100)
    query = url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()
    assert query["Expires"] == "100"
  end

  test "transfer/1", %{conn: conn} do
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(@upload)
    assert {:ok, _} = GoogleApi.Storage.V1.Api.Objects.storage_objects_get(conn, @bucket, key)
  end
end
