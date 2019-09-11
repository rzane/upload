defmodule Upload.Adapters.S3Test do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.S3

  alias Upload.Adapters.S3, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  defp ensure_bucket_exists! do
    with {:error, _} <- Adapter.bucket() |> ExAws.S3.head_bucket() |> ExAws.request() do
      Adapter.bucket() |> ExAws.S3.put_bucket("us-east-1") |> ExAws.request!()
    end
  end

  defp get_object(key) do
    Adapter.bucket() |> ExAws.S3.get_object(key) |> ExAws.request()
  end

  setup_all do
    ensure_bucket_exists!()
    :ok
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "https://my_bucket_name.s3.amazonaws.com/foo.txt"
    assert Adapter.get_url("foo/bar.txt") == "https://my_bucket_name.s3.amazonaws.com/foo/bar.txt"
  end

  test "get_signed_url/2" do
    assert {:ok, url} = Adapter.get_signed_url("foo.txt", [])
    query = url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()

    assert query["X-Amz-Algorithm"]
    assert query["X-Amz-Credential"]
    assert query["X-Amz-Date"]
    assert query["X-Amz-Expires"] == "3600"
    assert query["X-Amz-Signature"]
    assert query["X-Amz-SignedHeaders"]
  end

  test "get_signed_url/2 with a custom expiration" do
    assert {:ok, url} = Adapter.get_signed_url("foo.txt", expires_in: 100)
    query = url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()
    assert query["X-Amz-Expires"] == "100"
  end

  test "transfer/1" do
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(@upload)
    assert {:ok, %{body: "MEATLOAF\n"}} = get_object(key)
  end
end
