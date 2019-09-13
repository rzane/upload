defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @fields [:key, :filename, :content_type, :byte_size, :checksum]

      embedded_schema do
        field :key, :string
        field :filename, :string
        field :content_type, :string
        # field :metadata, :map
        field :byte_size, :integer
        field :checksum, :string
        timestamps(updated_at: false)
      end

      def changeset(upload, attrs \\ %{}) do
        upload
        |> cast(attrs, @fields)
        |> validate_required(:key)
      end
    end
  end

  def cast_upload(changeset, key) do
    changeset
    |> Ecto.Changeset.cast_embed(key)
  end
end
