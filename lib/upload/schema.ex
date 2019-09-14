defmodule Upload.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:key, :filename, :content_type, :byte_size, :checksum]
  @required_fields [:key, :filename]

  embedded_schema do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :metadata, :map
    field :byte_size, :integer
    field :checksum, :string
    timestamps(updated_at: false)
  end

  def changeset(upload, attrs \\ %{}) do
    upload
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
