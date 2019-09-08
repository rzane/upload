defmodule Upload.Adapters.GCSTest do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.GCS

  alias Upload.Adapters.GCS, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  @project System.get_env("GCS_PROJECT") || "whatever"
  @bucket Adapter.bucket()

  defp ensure_bucket_exists do
    {:ok, conn} = Adapter.build_connection()

    GoogleApi.Storage.V1.Api.Buckets.storage_buckets_insert(
      conn,
      @project,
      body: %{name: @bucket}
    )
  end

  defp get_object(key) do
    {:ok, conn} = Adapter.build_connection()
    GoogleApi.Storage.V1.Api.Objects.storage_objects_get(conn, @bucket, key)
  end

  setup_all do
    {:ok, _bucket} = ensure_bucket_exists()
    :ok
  end

  # test "get_url/1" do
  #   assert Adapter.get_url("foo.txt") == "https://my_bucket_name.s3.amazonaws.com/foo.txt"
  #   assert Adapter.get_url("foo/bar.txt") == "https://my_bucket_name.s3.amazonaws.com/foo/bar.txt"
  # end

  # test "get_signed_url/1" do
  #   assert {:ok, _} = Adapter.get_signed_url("foo.txt")
  # end

  test "transfer/1" do
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(@upload)
    assert {:ok, _} = get_object(key)
  end
end
