defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an uploaded file in the database.
  """

  # FIXME: Don't trust the `content_type`. Files should be identified
  # with the `file` command line utility.

  use Ecto.Schema

  alias Ecto.Changeset
  alias Upload.Key
  alias Upload.Utils

  @type key :: binary()
  @type id :: integer() | binary()

  @type t :: %__MODULE__{
          id: id(),
          key: key(),
          filename: binary(),
          content_type: binary() | nil,
          byte_size: integer(),
          checksum: binary(),
          metadata: map(),
          path: binary() | nil
        }

  @fields ~w(key filename content_type byte_size checksum)a
  @file_fields ~w(path filename)a
  @required_fields ~w(key filename byte_size checksum)a

  schema Utils.table_name() do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :byte_size, :integer
    field :checksum, :string
    field :metadata, :map
    field :path, :string, virtual: true
    timestamps(updated_at: false)
  end

  @spec from_plug(Plug.Upload.t()) :: Changeset.t()
  def from_plug(%Plug.Upload{} = upload) do
    from_file(Map.from_struct(upload))
  end

  @spec from_path(Path.t()) :: Changeset.t()
  def from_path(path) when is_binary(path) do
    from_file(%{path: path, filename: Path.basename(path)})
  end

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(%__MODULE__{} = upload, attrs \\ %{}) do
    upload
    |> Changeset.cast(attrs, @fields)
    |> put_key_lazy()
    |> Changeset.validate_required(@required_fields)
  end

  defp from_file(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @file_fields)
    |> put_key_lazy()
    |> put_file_info()
    |> Changeset.validate_required(@required_fields)
  end

  defp put_key_lazy(changeset) do
    case Changeset.get_change(changeset, :key) do
      nil -> Changeset.put_change(changeset, :key, Key.generate())
      _ -> changeset
    end
  end

  defp put_file_info(%Changeset{changes: %{path: path}} = changeset) when is_binary(path) do
    with {:ok, %{size: byte_size}} <- File.stat(path),
         {:ok, content_type} <- get_content_type(path),
         {:ok, checksum} <- FileStore.Stat.checksum_file(path),
         {:ok, metadata} <- Utils.analyze(path, content_type) do
      changeset
      |> Changeset.put_change(:byte_size, byte_size)
      |> Changeset.put_change(:checksum, checksum)
      |> Changeset.put_change(:metadata, metadata)
      |> Changeset.put_change(:content_type, content_type)
    else
      {:error, :enoent} ->
        Changeset.add_error(changeset, :path, "does not exist")

      {:error, reason} ->
        Changeset.add_error(changeset, :path, "is invalid", reason: reason)
    end
  end

  defp get_content_type(path) do
    case FileType.from_path(path) do
      {:ok, {_, mime}} -> {:ok, mime}
      {:error, :unrecognized} -> {:ok, "application/octet-stream"}
      {:error, reason} -> {:error, reason}
    end
  end
end
