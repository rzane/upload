defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an upload in the database.
  """

  use Ecto.Schema

  alias Ecto.UUID
  alias Ecto.Changeset
  alias Upload.Analyzer

  @type t() :: %__MODULE__{}

  @table_name Application.get_env(:upload, :table_name, "upload_blobs")

  @required_fields [:path, :filename]
  @optional_fields [:content_type]

  schema @table_name do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :metadata, :map
    field :byte_size, :integer
    field :checksum, :string
    field :path, :string, virtual: true
    timestamps(updated_at: false)
  end

  @spec from_plug(Plug.Upload.t()) :: Changeset.t()
  def from_plug(%Plug.Upload{} = upload) do
    changeset(%Upload.Blob{}, Map.from_struct(upload))
  end

  @spec from_path(Path.t()) :: Changeset.t()
  def from_path(path) do
    changeset(
      %Upload.Blob{},
      %{
        path: path,
        filename: Path.basename(path),
        content_type: MIME.from_path(path)
      }
    )
  end

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(%__MODULE__{} = upload, attrs \\ %{}) do
    upload
    |> Changeset.cast(attrs, @required_fields ++ @optional_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.prepare_changes(&perform_upload/1)
  end

  defp perform_upload(changeset) do
    key = UUID.generate()
    store = Upload.get_file_store()
    path = Changeset.get_change(changeset, :path)
    content_type = Changeset.get_change(changeset, :content_type)

    with {:ok, byte_size} <- Analyzer.byte_size(path),
         {:ok, checksum} <- Analyzer.checksum(path),
         {:ok, metadata} <- Analyzer.metadata(path, content_type),
         :ok <- FileStore.copy(store, path, key) do
      changeset
      |> Changeset.put_change(:key, key)
      |> Changeset.put_change(:byte_size, byte_size)
      |> Changeset.put_change(:checksum, checksum)
      |> Changeset.put_change(:metadata, metadata)
    else
      {:error, reason} ->
        put_error(changeset, reason)

      :error ->
        put_error(changeset, "transfer failed")
    end
  end

  defp put_error(changeset, reason) do
    Changeset.add_error(changeset, :base, "upload failed", reason: reason)
  end
end
