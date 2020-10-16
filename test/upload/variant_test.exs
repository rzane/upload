defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Storage
  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Analyzer.Image
  alias FileStore.Adapters.Memory

  describe "new/2" do
    test "describes a variant" do
      blob = %Blob{key: "abc"}
      variant = Variant.new(blob, resize: "200x200")

      assert variant.blob == blob
      assert variant.transforms == [resize: "200x200"]
      assert variant.key =~ ~r|^variants/abc/[a-z0-9]{64}$|
    end
  end

  describe "process/2" do
    @path Path.expand("../fixtures/racecar.jpg", __DIR__)

    setup do
      start_supervised!(Memory)
      :ok
    end

    test "transforms an image" do
      blob = %Blob{key: "abc"}
      variant = Variant.new(blob, resize: "10x10")

      assert :ok = Storage.upload(@path, blob.key)
      assert :ok = Variant.process(variant)
      assert {:ok, _} = Storage.stat(variant.key)
      assert {:ok, tmp} = Plug.Upload.random_file("upload_test")
      assert :ok = Storage.download(variant.key, tmp)
      assert {:ok, %{width: 10, height: 7}} = Image.analyze(tmp)
      assert :ok = File.rm(tmp)
    end
  end
end
