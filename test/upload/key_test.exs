defmodule Upload.KeyTest do
  use ExUnit.Case, async: true

  alias Upload.Key

  describe "generate_key/0" do
    test "generates 28-character, base36-encoded key" do
      for _ <- 0..10 do
        assert Key.generate() =~ ~r/^[a-z0-9]{28}$/
      end
    end
  end
end
