defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  defstruct [:path, :content_type, :filename]

  defmodule Uploader do
    @callback store() :: FileStore.t()
  end

  defmacro __using__(_) do
    quote do
      @behaviour Uploader

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
        |> validate_required([:key, :filename])
      end
    end
  end

  def cast_upload(changeset, field, uploader) do
    case Map.get(changeset.params, field) do
      %Plug.Upload{path: path, content_type: content_type, filename: filename} ->
        upload = %Upload{path: path, content_type: content_type, filename: filename}
        put_upload(changeset, field, upload)

      %Upload{} = upload ->
        put_upload(changeset, field, upload)

      _ ->
        changeset
    end
  end

  def put_upload(changeset, field, %Upload{} = upload) do
    store = %FileStore{} #TODO: get it from the changeset based on field name
    key = Ecto.UUID.generate()

    changeset
    |> cast_embed(field)
    |> prepare_changes(fn ->
      case FileStore.copy(store, upload.path, key) do
        :ok ->
          cast_embed(changeset, field)

        :error ->
          add_error(changeset, field, "unable to upload")
      end
    end)
  end
end
