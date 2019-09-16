defmodule Upload.KeyTest do
  use ExUnit.Case
  alias Upload.Key

  test "generates 28-character, base36-encoded key" do
    for _ <- 0..100 do
      assert Key.generate() =~ ~r/^[a-z0-9]{28}$/
    end
  end
end
