defmodule Upload.Adapters.TestTest do
  use ExUnit.Case, async: true

  alias Upload.Adapters.Test, as: Adapter

  doctest Upload.Adapters.Test

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)

  setup do
    {:ok, _} = start_supervised(Upload.Adapters.Test)
    :ok
  end

  test "get_uploads/1 and put_upload/1" do
    assert Adapter.get_uploads == %{}

    Adapter.put_upload(%Upload{
      key: "123.png",
      path: "/path/to/foo.png",
      filename: "foo.png"
    })

    assert Adapter.get_uploads == %{
      "123.png" => %Upload{
        filename: "foo.png",
        key: "123.png",
        path: "/path/to/foo.png",
        status: :pending
      }
    }
  end

  test "transfer/1 adds the upload to state" do
    assert Adapter.get_uploads == %{}
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, %Upload{key: key}} = Adapter.transfer(upload)
    assert %Upload{} = Map.get(Adapter.get_uploads(), key)
  end

  test "get_url/1 just returns the key" do
    assert Adapter.get_url("foo/bar.txt") == "foo/bar.txt"
  end
end
