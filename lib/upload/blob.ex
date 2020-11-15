defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an uploaded file in the database.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Upload.Key
  alias Upload.Stat

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
  @required_fields ~w(key filename byte_size checksum)a

  schema "blobs" do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :byte_size, :integer
    field :checksum, :string
    field :metadata, :map
    field :path, :string, virtual: true
    timestamps(updated_at: false)
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = upload, attrs \\ %{}) do
    upload
    |> cast(attrs, @fields)
    |> put_new_key()
    |> validate_required(@required_fields)
  end

  defp put_new_key(changeset) do
    case get_field(changeset, :key) do
      nil -> put_change(changeset, :key, Key.generate())
      _ -> changeset
    end
  end

  @spec from_plug(Plug.Upload.t()) :: Ecto.Changeset.t()
  def from_plug(%Plug.Upload{path: path} = upload) when is_binary(path) do
    opts =
      upload
      |> Map.take([:filename, :content_type])
      |> Enum.into([])

    from_path(path, opts)
  end

  @spec from_path(Path.t()) :: {:ok, Ecto.Changeset.t()} | {:error, Stat.error()}
  def from_path(path) when is_binary(path) do
    from_path(path, [])
  end

  defp from_path(path, opts) do
    with {:ok, stat} <- Stat.stat(path) do
      {:ok, from_stat(stat, opts)}
    end
  end

  defp from_stat(stat, opts) do
    changeset(%__MODULE__{}, stat |> Map.from_struct() |> merge(opts))
  end

  defp merge(attrs, opts) do
    opts
    |> Enum.reduce(opts, attrs, fn {key, opt}, acc ->
      Map.update!(acc, &merge(key, &1, opt))
    end)
    |> Enum.into(%{})
  end

  @octet_stream "application/octet-stream"
  defp merge(_key, opt, nil), do: opt
  defp merge(:content_type, opt, @octet_stream), do: opt
  defp merge(:content_type, _opt, value), do: value
  defp merge(_key, opt, _value), do: opt
end
