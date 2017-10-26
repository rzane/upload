defmodule Upload.Adapters.S3Test do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.S3

  alias Upload.Adapters.S3, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)

  defp bucket_exists? do
    case Adapter.bucket |> ExAws.S3.head_bucket |> ExAws.request do
      {:ok, _} -> true
      _        -> false
    end
  end

  defp delete_objects! do
    %{body: %{contents: objects}} =
      Adapter.bucket
      |> ExAws.S3.list_objects
      |> ExAws.request!

    Enum.each(objects, fn object ->
      Adapter.bucket
      |> ExAws.S3.delete_object(object.key)
      |> ExAws.request!
    end)
  end

  defp delete_bucket! do
    Adapter.bucket |> ExAws.S3.delete_bucket |> ExAws.request!
  end

  defp create_bucket! do
    Adapter.bucket |> ExAws.S3.put_bucket("us-east-1") |> ExAws.request!
  end

  defp get_object(key) do
    Adapter.bucket |> ExAws.S3.get_object(key) |> ExAws.request
  end

  setup do
    if bucket_exists?() do
      delete_objects!()
      delete_bucket!()
    end

    create_bucket!()
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
