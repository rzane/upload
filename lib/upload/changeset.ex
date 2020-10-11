defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob

  @spec cast_upload(Changeset.t(), atom()) :: Changeset.t()
  def cast_upload(changeset, field) do
    case Map.fetch(changeset.params, to_string(field)) do
      {:ok, %Changeset{} = blob_changeset} ->
        Changeset.put_assoc(changeset, field, blob_changeset)

      {:ok, %{__struct__: Plug.Upload} = plug_upload} ->
        Changeset.put_assoc(
          changeset,
          field,
          Blob.from_plug(plug_upload)
        )

      {:ok, _other} ->
        Changeset.add_error(changeset, field, "is invalid")

      :error ->
        changeset
    end
  end
end
