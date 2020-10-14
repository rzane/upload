defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an uploaded file in the database.
  """

  use Ecto.Schema

  alias Ecto.Changeset
  alias Upload.Utils
  alias Upload.Key

  alias Upload.Analyzer.Image
  alias Upload.Analyzer.Video

  @type t() :: %__MODULE__{}

  @fields ~w(key filename content_type byte_size checksum)a
  @required_fields ~w(key filename byte_size checksum)a

  @file_fields ~w(path filename content_type)a
  @required_file_fields ~w(path filename)a

  schema Utils.get_config(__MODULE__, :table_name, "blobs") do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :byte_size, :integer
    field :checksum, :string
    field :metadata, :map
    field :path, :string, virtual: true
    timestamps(updated_at: false)
  end

  @spec from_plug(%{__struct__: Plug.Upload}) :: Changeset.t()
  def from_plug(%{__struct__: Plug.Upload} = upload) do
    from_file(Map.from_struct(upload))
  end

  @spec from_path(Path.t()) :: Changeset.t()
  def from_path(path) do
    from_file(%{
      key: Key.generate(),
      path: path,
      filename: Path.basename(path),
      content_type: MIME.from_path(path)
    })
  end

  defp from_file(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @file_fields)
    |> Changeset.validate_required(@required_file_fields)
    |> Changeset.put_change(:key, Key.generate())
    |> Changeset.prepare_changes(&analyze/1)
  end

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(%__MODULE__{} = upload, attrs \\ %{}) do
    upload
    |> Changeset.cast(attrs, @fields)
    |> Changeset.validate_required(@required_fields)
  end

  defp analyze(changeset) do
    path = Changeset.fetch_change!(changeset, :path)
    content_type = Changeset.get_change(changeset, :content_type)

    with {:ok, %{size: byte_size}} <- File.stat(path),
         {:ok, checksum} <- FileStore.Stat.checksum_file(path),
         {:ok, metadata} <- get_metadata(path, content_type) do
      changeset
      |> Changeset.put_change(:byte_size, byte_size)
      |> Changeset.put_change(:checksum, checksum)
      |> Changeset.put_change(:metadata, metadata)
    else
      {:error, reason} ->
        Changeset.add_error(changeset, :path, "is invalid", reason: reason)
    end
  end

  defp get_metadata(path, "image/" <> _), do: Image.get_metadata(path)
  defp get_metadata(path, "video/" <> _), do: Video.get_metadata(path)
  defp get_metadata(_path, _), do: {:ok, %{}}
end
