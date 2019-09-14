defmodule Upload.Blob do
  @moduledoc """
  An `Ecto.Schema` that represents an upload in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @table_name Application.get_env(:upload, :table_name, "upload_blobs")

  @optional_fields [:content_type, :metadata]
  @required_fields [:key, :filename, :byte_size, :checksum]

  schema @table_name do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :metadata, :map
    field :byte_size, :integer
    field :checksum, :string
    timestamps(updated_at: false)
  end

  @spec changeset(Upload.Blob.t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = upload, attrs \\ %{}) do
    upload
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
