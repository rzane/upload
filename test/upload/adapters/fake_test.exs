defmodule Upload.Adapters.FakeTest do
  use ExUnit.Case, async: true
  doctest Upload.Adapters.Fake

  alias Upload.Adapters.Fake, as: Adapter

  @fixture Path.expand("../../fixtures/text.txt", __DIR__)
  @upload %Upload{path: @fixture, filename: "text.txt", key: "foo/text.txt"}

  test "get_url/1" do
    assert Adapter.get_url("foo/bar.txt") == "foo/bar.txt"
  end

  test "get_signed_url/1" do
    assert Adapter.get_signed_url("foo/bar.txt") == {:ok, "foo/bar.txt"}
  end

  test "transfer/1" do
    assert {:ok, %Upload{status: :transferred}} = Adapter.transfer(@upload)
  end
end
