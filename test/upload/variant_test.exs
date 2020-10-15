defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Variant
  alias Upload.Analyzer.Image
  alias FileStore.Adapters.Memory

  describe "new/2" do
    test "describes a variant" do
      variant = Variant.new("abc", resize: "200x200")
      assert variant.blob_key == "abc"
      assert variant.transforms == [resize: "200x200"]
      assert variant.key =~ ~r|^variants/abc/[a-z0-9]{64}$|
    end
  end

  describe "process/2" do
    @path Path.expand("../fixtures/racecar.jpg", __DIR__)

    setup do
      start_supervised!(Memory)
      [store: FileStore.new(adapter: Memory)]
    end

    test "transforms an image", %{store: store} do
      variant = Variant.new("abc", resize: "10x10")

      assert :ok = FileStore.upload(store, @path, variant.blob_key)
      assert :ok = Variant.process(variant)
      assert {:ok, _} = FileStore.stat(store, variant.key)
      assert {:ok, tmp} = Plug.Upload.random_file("upload_test")
      assert :ok = FileStore.download(store, variant.key, tmp)
      assert {:ok, %{width: 10, height: 7}} = Image.get_metadata(tmp)
      assert :ok = File.rm(tmp)
    end
  end
end
