defmodule Upload.Adapters.S3Test do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Upload.Adapters.S3

  alias Upload.Adapters.S3, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  defp ensure_bucket_exists! do
    with {:error, _ } <- Adapter.bucket |> ExAws.S3.head_bucket |> ExAws.request do
      Adapter.bucket |> ExAws.S3.put_bucket("us-east-1") |> ExAws.request!
    end
  end

  defp get_object(key) do
    Adapter.bucket |> ExAws.S3.get_object(key) |> ExAws.request
  end

  setup_all do
    ExVCR.Config.cassette_library_dir("test/fixtures/cassettes")

    use_cassette "s3/setup" do
      ensure_bucket_exists!()
    end

    :ok
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "https://my_bucket_name.s3.amazonaws.com/foo.txt"
    assert Adapter.get_url("foo/bar.txt") == "https://my_bucket_name.s3.amazonaws.com/foo/bar.txt"
  end

  test "transfer/1" do
    use_cassette "s3/transfer" do
      assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(@upload)
      assert {:ok, %{body: "MEATLOAF\n"}} = get_object(key)
    end
  end
end
