defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an upload in the database.
  """

  require Logger

  use Ecto.Schema

  alias Ecto.Changeset
  alias Upload.Config
  alias Upload.Key
  alias Upload.Analyzer.Image
  alias Upload.Analyzer.Video

  @type t() :: %__MODULE__{}

  @required_fields [:path, :filename]
  @optional_fields [:content_type]

  schema Config.table_name() do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :metadata, :map
    field :byte_size, :integer
    field :checksum, :string
    field :path, :string, virtual: true
    timestamps(updated_at: false)
  end

  @spec from_plug(%{__struct__: Plug.Upload}) :: Changeset.t()
  def from_plug(%{__struct__: Plug.Upload} = upload) do
    changeset(%__MODULE__{}, Map.from_struct(upload))
  end

  @spec from_path(Path.t()) :: Changeset.t()
  def from_path(path) do
    changeset(
      %__MODULE__{},
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
    path = Changeset.get_change(changeset, :path)
    content_type = Changeset.get_change(changeset, :content_type)

    key = Key.generate()
    byte_size = get_byte_size(path)
    checksum = get_checksum(path)
    metadata = get_metadata(path, content_type)

    case FileStore.upload(Config.file_store(), path, key) do
      :ok ->
        log("Uploaded file to key: #{key} (checksum: #{checksum})")

        changeset
        |> Changeset.put_change(:key, key)
        |> Changeset.put_change(:byte_size, byte_size)
        |> Changeset.put_change(:checksum, checksum)
        |> Changeset.put_change(:metadata, metadata)

      {:error, reason} ->
        Changeset.add_error(changeset, :base, "upload failed", reason: reason)
    end
  end

  defp get_byte_size(path) do
    path
    |> File.stat!()
    |> Map.fetch!(:size)
  end

  defp get_checksum(path) do
    path
    |> File.stream!([], 2_048)
    |> Enum.reduce(:crypto.hash_init(:md5), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  defp get_metadata(path, content_type) do
    case do_get_metadata(path, content_type) do
      {:ok, metadata} ->
        metadata

      {:info, message} ->
        log(message)

      {:error, message} ->
        Logger.error(message)
    end
  end

  defp do_get_metadata(path, content_type) do
    case content_type do
      "image/" <> _ -> Image.get_metadata(path, content_type)
      "video/" <> _ -> Video.get_metadata(path, content_type)
      _ -> {:ok, %{}}
    end
  end

  defp log(message) do
    Logger.log(Config.log_level(), message)
  end
end
