defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      embedded_schema do
        field :key, :string
        field :filename, :string
        field :content_type, :string
        field :metadata, :map
        field :byte_size, :integer
        field :checksum, :string
        timestamps(updated_at: false)
      end
    end
  end

  def cast_upload(key, uploader) do
  end
end
