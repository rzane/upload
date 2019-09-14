defmodule Upload.Changeset do
  @spec cast_upload(Changeset.t(), atom()) :: Changeset.t()
  def cast_upload(changeset, field) do
    case Map.fetch(changeset.params, to_string(field)) do
      {:ok, %Ecto.Changeset{} = blob_changeset} ->
        Ecto.Changeset.put_assoc(changeset, field, blob_changeset)

      {:ok, %Plug.Upload{} = plug_upload} ->
        Ecto.Changeset.put_assoc(
          changeset,
          field,
          Upload.Blob.from_plug(plug_upload)
        )

      {:ok, _other} ->
        Ecto.Changeset.add_error(changeset, field, "is invalid")

      :error ->
        changeset
    end
  end
end
