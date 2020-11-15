defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an uploaded file in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Upload.Key

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

  @fields ~w(key filename content_type byte_size checksum path)a
  @required_fields @fields -- ~w(metadata path)a

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
  def changeset(blob, attrs \\ %{}) when is_map(attrs) do
    blob
    |> cast(attrs, @fields)
    |> generate_key()
    |> validate_required(@required_fields)
  end

  defp generate_key(changeset) do
    case get_field(changeset, :key) do
      nil -> put_change(changeset, :key, Key.generate())
      _ -> changeset
    end
  end
end
