defmodule Upload.Adapters.LocalTest do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.Local

  alias Upload.Adapters.Local, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  setup do
    {:ok, _} = File.rm_rf(Adapter.storage_path())
    :ok
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "/uploads/foo.txt"
    assert Adapter.get_url("foo/bar.txt") == "/uploads/foo/bar.txt"
  end

  test "transfer/1" do
    assert {:ok, %Upload{key: key, status: :transferred}} = Adapter.transfer(@upload)
    assert File.exists?(Path.join(Adapter.storage_path(), key))
  end
end
