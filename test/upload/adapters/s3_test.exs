defmodule Upload.Adapters.S3Test do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.S3

  alias Upload.Adapters.S3, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)

  defp ensure_bucket_exists! do
    with {:error, _ } <- Adapter.bucket |> ExAws.S3.head_bucket |> ExAws.request do
      Adapter.bucket |> ExAws.S3.put_bucket("us-east-1") |> ExAws.request!
    end
  end

  defp get_object(key) do
    Adapter.bucket |> ExAws.S3.get_object(key) |> ExAws.request
  end

  setup_all do
    ensure_bucket_exists!()
    :ok
  end

  test "transfer/1" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(upload)
    assert {:ok, %{body: "MEATLOAF\n"}} = get_object(key)
  end

  test "transfer/1 with prefix" do
    assert {:ok, upload} = Upload.cast_path(@fixture, prefix: ["meatloaf"])
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(upload)
    assert {:ok, %{body: "MEATLOAF\n"}} = get_object(key)
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "http://my_bucket_name.s3.amazonaws.com/foo.txt"
    assert Adapter.get_url("foo/bar.txt") == "http://my_bucket_name.s3.amazonaws.com/foo/bar.txt"
  end
end
