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
    variation = Key.encode(@transforms)
    [blob: blob, variation: variation]
  end

  test "decode/2", %{blob: blob, variation: variation} do
    assert {:ok, variant} = Variant.decode(blob, variation)
    assert variant.blob == blob
    assert variant.transforms == @transforms
    assert variant.key == Key.generate_variant(blob.key, variation)
  end

  test "create/2", %{blob: blob, variation: variation} do
    assert {:ok, variant} = Variant.decode(blob, variation)
    assert {:ok, ^variant} = Variant.create(variant)
  end
end
