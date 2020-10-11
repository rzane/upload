defmodule Upload.UploaderTest do
  use ExUnit.Case, async: true
  alias FileStore.Adapters.Memory, as: Adapter

  @fixture Path.expand("../fixtures/test.txt", __DIR__)

  defmodule MyUploader do
    use Upload.Uploader

    def cast(file, _opts \\ []) do
      with {:ok, upload} <- Upload.cast(file, prefix: ["logos"]) do
        extension = Upload.get_extension(upload)

        if extension in ~w(.png) do
          {:ok, upload}
        else
          {:error, "invalid"}
        end
      end
    end
  end

  setup do
    assert {:ok, _} = start_supervised(Adapter)
    :ok
  end

  test "delegates by default" do
    assert {:ok, upload} = MyUploader.cast_path(@fixture)
    assert {:ok, %Upload{}} = MyUploader.transfer(upload)
  end

  test "allows overriding the cast behavior" do
    good = %Plug.Upload{path: "/path/to/foo.png", filename: "foo.png"}
    bad = %Plug.Upload{path: "/path/to/foo.jpg", filename: "foo.jpg"}

    assert {:ok, %Upload{}} = MyUploader.cast(good)
    assert {:error, "invalid"} = MyUploader.cast(bad)
  end
end
