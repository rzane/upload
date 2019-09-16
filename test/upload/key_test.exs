defmodule Upload.KeyTest do
  use ExUnit.Case
  alias Upload.Key

  describe "generate/0" do
    test "generates 28-character, base36-encoded key" do
      for _ <- 0..100 do
        assert Key.generate() =~ ~r/^[a-z0-9]{28}$/
      end
    end
  end

  describe "generate_variant/1" do
    test "stores the variation in a digest" do
      assert "variants/foo/" <> digest = Key.generate_variant("foo", "bar")
      assert "variants/foo/" <> ^digest = Key.generate_variant("foo", "bar")
    end
  end

  describe "encode/1 and decode/1" do
    test "generates a signed token" do
      data = %{"foo" => "bar"}
      token = Key.encode(data)
      assert Key.decode(token) == {:ok, data}
    end
  end
end
