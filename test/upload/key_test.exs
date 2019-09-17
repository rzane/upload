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

  describe "sign/2 and verify/2" do
    test "saves data in a token" do
      data = %{"foo" => "bar"}
      token = Key.sign(data, :foo)
      assert Key.verify(token, :foo) == {:ok, data}
    end

    test "errors when purpose does not match" do
      data = %{"foo" => "bar"}
      token = Key.sign(data, :foo)
      assert Key.verify(token, :bar) == :error
    end
  end
end
