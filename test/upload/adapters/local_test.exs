defmodule Upload.Adapters.LocalTest do
  use ExUnit.Case, async: true

  doctest Upload.Adapters.Local

  alias Upload.Adapters.Local, as: Adapter

  @storage Path.expand("../../../priv/static/uploads", __DIR__)
  @fixture Path.expand("../../fixtures/text.txt", __DIR__)

  setup do
    {:ok, _} = File.rm_rf @storage
    :ok
  end

  test "transfer/1" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, %Upload{key: key, status: :completed}} = Adapter.transfer(upload)
    assert File.exists?(Path.join(@storage, key))
  end

  test "transfer/1 with prefix" do
    assert {:ok, upload} = Upload.cast_path(@fixture, prefix: ["meatloaf"])
    assert {:ok, %Upload{key: key, status: :completed}} = Adapter.transfer(upload)
    assert File.exists?(Path.join(@storage, key))
  end

  test "get_url/1" do
    assert {:ok, upload} = Upload.cast_path(@fixture)
    assert {:ok, %Upload{key: key}} = Adapter.transfer(upload)
    assert Adapter.get_url(key) =~ ~r"^/uploads/[a-z0-9]{32}\.txt$"
  end
end
