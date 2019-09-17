defmodule Upload.VariantTest do
  use ExUnit.Case

  alias Upload.Key
  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Test.Repo
  alias FileStore.Adapters.Test, as: Storage

  @png_path "test/fixtures/test.png"
  @transforms %{"resize" => "50x50"}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(Storage)

    blob = @png_path |> Blob.from_path() |> Repo.insert!()
    transform_key = Key.sign(@transforms, :transform)
    [blob: blob, transform_key: transform_key]
  end

  test "decode/2", %{blob: blob, transform_key: transform_key} do
    assert {:ok, variant} = Variant.decode(blob.key, transform_key)
    assert variant.blob_key == blob.key
    assert variant.transforms == @transforms
    assert variant.key == Key.generate_variant(blob.key, transform_key)
  end

  test "process/1", %{blob: blob, transform_key: transform_key} do
    assert {:ok, variant} = Variant.decode(blob.key, transform_key)
    assert {:ok, ^variant} = Variant.process(variant)
  end
end
