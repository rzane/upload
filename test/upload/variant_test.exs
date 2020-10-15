defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Blob
  alias Upload.Variant

  describe "generate_key/2" do
    test "generates a deterministic key to be used for storage" do
      blob = %Blob{key: "abc"}
      key = Variant.generate_key(blob, resize: "200x200")
      assert key =~ ~r|^variants/abc/[a-z0-9]{64}$|

      for _ <- 1..10 do
        assert Variant.generate_key(blob, resize: "200x200") == key
      end
    end
  end
end
