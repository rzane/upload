defmodule Upload.EctoTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset, only: [get_field: 2]

  doctest Upload.Ecto

  alias Upload.Adapters.Test, as: Adapter

  @fixture Path.expand("../fixtures/text.txt", __DIR__)
  @filename ~r"^[a-z0-9]{32}\.txt$"

  defmodule Company do
    use Ecto.Schema
    schema "companies", do: field :logo, :string

    def change(params \\ %{}) do
      %__MODULE__{}
      |> Ecto.Changeset.cast(params, [])
    end
  end

  defmodule CustomUploader do
    def cast(value, _opts), do: {:error, "cast: #{value}"}
    def cast_path(value, _opts), do: {:error, "cast path: #{value}"}
    def transfer(_value), do: {:error, "PANIC!!!"}
  end

  defmodule BrokenUploader do
    def cast(_value, _opts), do: {:error, %{foo: "bar"}}
    def cast_path(_value, _opts), do: {:error, %{foo: "bar"}}
    def transfer(_value), do: {:error, %{foo: "bar"}}
  end

  setup do
    assert {:ok, _} = start_supervised(Adapter)
    assert {:ok, upload} = Upload.cast_path(@fixture)

    plug_upload = %Plug.Upload{
      path: upload.path,
      filename: upload.filename
    }

    [upload: upload, plug_upload: plug_upload]
  end

  defp run_prepared_changes(%Ecto.Changeset{prepare: prepare} = cs) do
    Enum.reduce(prepare, cs, fn fun, acc -> fun.(acc) end)
  end

  describe "put_upload/4" do
    test "transfers the file after changes are prepared", %{upload: upload} do
      changeset = Company.change
      changeset = Upload.Ecto.put_upload(changeset, :logo, upload)

      assert Map.size(Adapter.get_uploads) == 0
      run_prepared_changes(changeset)
      assert Map.size(Adapter.get_uploads) == 1
    end

    test "assigns the key", %{upload: upload} do
      changeset = Company.change
      changeset = Upload.Ecto.put_upload(changeset, :logo, upload)
      assert get_field(changeset, :logo)
    end

    test "assigns uploads that have already been transferred", %{upload: upload} do
      upload = %Upload{upload | status: :transferred}
      changeset = Company.change
      changeset = Upload.Ecto.put_upload(changeset, :logo, upload)
      assert get_field(changeset, :logo)
    end

    test "accepts custom uploader and handles errors", %{upload: upload} do
      changeset = Company.change
      changeset = Upload.Ecto.put_upload(changeset, :logo, upload, with: CustomUploader)
      changeset = run_prepared_changes(changeset)
      assert changeset.errors == [logo: {"PANIC!!!", []}]
    end

    test "falls back to an ambiguous error message", %{upload: upload} do
      changeset = Company.change
      changeset = Upload.Ecto.put_upload(changeset, :logo, upload, with: BrokenUploader)
      changeset = run_prepared_changes(changeset)
      assert changeset.errors == [logo: {"failed to upload", []}]
    end
  end

  describe "cast_upload/3" do
    def cast_and_upload(logo, opts \\ []) do
      %{"logo" => logo}
      |> Company.change
      |> Upload.Ecto.cast_upload(:logo, opts)
      |> run_prepared_changes()
    end

    test "casts and assigns a %Plug.Upload{}", %{plug_upload: plug_upload} do
      changeset = cast_and_upload(plug_upload)
      assert get_field(changeset, :logo) =~ @filename
    end

    test "casts and assigns a %Plug.Upload{} with :prefix", %{plug_upload: plug_upload} do
      changeset = cast_and_upload(plug_upload, prefix: ["logos"])
      assert get_field(changeset, :logo) =~ ~r"^logos/[a-z0-9]{32}\.txt$"
    end

    test "casts and assigns an %Upload{}", %{upload: upload} do
      changeset = cast_and_upload(upload)
      assert get_field(changeset, :logo) =~ @filename
    end

    test "ignores uncastable values" do
      changeset = cast_and_upload("meatloaf")
      refute get_field(changeset, :logo)
      assert changeset.errors == []
    end

    test "accepts custom uploader and handles errors" do
      changeset = cast_and_upload("meatloaf", with: CustomUploader)
      assert changeset.errors == [logo: {"cast: meatloaf", []}]
    end

    test "raises when it receives an invalid signature" do
      assert_raise RuntimeError, fn ->
        cast_and_upload("meatloaf", with: BrokenUploader)
      end
    end
  end

  describe "cast_upload_path/3" do
    defp cast_and_upload_path(logo, opts \\ []) do
      %{"logo" => logo}
      |> Company.change
      |> Upload.Ecto.cast_upload_path(:logo, opts)
      |> run_prepared_changes()
    end

    test "casts and assigns a path" do
      changeset = cast_and_upload_path(@fixture)
      assert get_field(changeset, :logo) =~ @filename
    end

    test "casts and assigns a path with :prefix" do
      changeset = cast_and_upload_path(@fixture, prefix: ["logos"])
      assert get_field(changeset, :logo) =~ ~r"^logos/[a-z0-9]{32}\.txt$"
    end

    test "casts and assigns an %Upload{}", %{upload: upload} do
      changeset = cast_and_upload_path(upload)
      assert get_field(changeset, :logo) =~ @filename
    end

    test "ignores uncastable values", %{plug_upload: plug_upload} do
      changeset = cast_and_upload_path(plug_upload)
      refute get_field(changeset, :logo)
      assert changeset.errors == []
    end

    test "accepts custom uploader and handles errors" do
      changeset = cast_and_upload_path("meatloaf", with: CustomUploader)
      assert changeset.errors == [logo: {"cast path: meatloaf", []}]
    end

    test "raises when it receives an invalid signature" do
      assert_raise RuntimeError, fn ->
        cast_and_upload_path("meatloaf", with: BrokenUploader)
      end
    end
  end

  describe "composing casters" do
    defp cast_and_upload_any(logo, opts \\ []) do
      %{"logo" => logo}
      |> Company.change
      |> Upload.Ecto.cast_upload(:logo, opts)
      |> Upload.Ecto.cast_upload_path(:logo, opts)
      |> run_prepared_changes()
    end

    test "casts and assigns %Plug.Upload{}", %{upload: upload} do
      changeset = cast_and_upload_any(upload)
      assert get_field(changeset, :logo) =~ @filename
    end

    test "casts and assigns path" do
      changeset = cast_and_upload_any(@fixture)
      assert get_field(changeset, :logo) =~ @filename
    end
  end
end
