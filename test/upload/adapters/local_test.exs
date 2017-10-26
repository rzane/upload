defmodule Upload.Adapters.LocalTest do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.Local

  alias Upload.Adapters.Local, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)

  setup do
    {:ok, _} = File.rm_rf(Adapter.storage_path)
    :ok
  end

  test "transfer/1" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, %Upload{key: key, status: :completed}} = Adapter.transfer(upload)
    assert File.exists?(Path.join(Adapter.storage_path, key))
  end

  test "transfer/1 with prefix" do
    assert {:ok, upload} = Upload.cast_path(@fixture, prefix: ["meatloaf"])
    assert {:ok, %Upload{key: key, status: :completed}} = Adapter.transfer(upload)
    assert File.exists?(Path.join(Adapter.storage_path, key))
  end

  test "get_url/1" do
    assert Adapter.get_url("foo.txt") == "/uploads/foo.txt"
    assert Adapter.get_url("foo/bar.txt") == "/uploads/foo/bar.txt"
  end
end
