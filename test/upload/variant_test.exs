defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Storage
  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Analyzer.Image
  alias FileStore.Adapters.Memory

  @blob %Blob{key: "abc"}
  @transforms [resize: "200x200"]

  describe "new/2" do
    test "constructs a new variant" do
      variant = Variant.new(@blob)
      assert variant.blob == @blob
      assert variant.transforms == []
    end

    test "describes a variant" do
      variant = Variant.new(@blob, @transforms)
      assert variant.blob == @blob
      assert variant.transforms == @transforms
    end
  end

  describe "transform/2" do
    test "appends transformations" do
      variant = Variant.new(@blob, foo: "bar")
      variant = Variant.transform(variant, biz: "buzz")
      assert variant.blob == @blob
      assert variant.transforms == [foo: "bar", biz: "buzz"]
    end
  end

  describe "create/1" do
    @path Path.expand("../fixtures/racecar.jpg", __DIR__)

    setup do
      start_supervised!(Memory)
      :ok
    end

    test "transforms an image" do
      variant = Variant.new(@blob, resize: "10x10")
      assert :ok = Storage.upload(@path, @blob.key)
      assert {:ok, key} = Variant.create(variant)
      assert {:ok, _} = Storage.stat(key)
      assert {:ok, tmp} = Plug.Upload.random_file("upload_test")
      assert :ok = Storage.download(key, tmp)
      assert {:ok, %{width: 10, height: 7}} = Image.analyze(tmp)
      assert :ok = File.rm(tmp)
    end
  end
end
