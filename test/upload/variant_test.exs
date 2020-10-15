defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Variant
  alias Upload.Analyzer.Image
  alias FileStore.Adapters.Memory

  describe "generate_key/2" do
    test "generates a deterministic key to be used for storage" do
      key = Variant.generate_key("abc", resize: "200x200")
      assert key =~ ~r|^variants/abc/[a-z0-9]{64}$|

      for _ <- 1..10 do
        assert Variant.generate_key("abc", resize: "200x200") == key
      end
    end
  end

  describe "process/2" do
    @blob_key "abc"
    @path Path.expand("../fixtures/racecar.jpg", __DIR__)

    setup do
      start_supervised!(Memory)
      [store: FileStore.new(adapter: Memory)]
    end

    test "transforms an image", %{store: store} do
      assert :ok = FileStore.upload(store, @path, @blob_key)
      assert {:ok, variant_key} = Variant.process(@blob_key, resize: "10x10")
      assert {:ok, _} = FileStore.stat(store, variant_key)
      assert {:ok, tmp} = Plug.Upload.random_file("upload_test")
      assert :ok = FileStore.download(store, variant_key, tmp)
      assert {:ok, %{width: 10, height: 7}} = Image.get_metadata(tmp)
      assert :ok = File.rm(tmp)
    end
  end
end
