defmodule Upload.Changeset do
  @doc """
  Apply an upload to an changeset.
  """

  alias Ecto.Changeset

  @spec cast_upload(Changeset.t(), atom()) :: Changeset.t()
  def cast_upload(changeset, field) do
    with {:ok, upload} <- Map.fetch(changeset.params, to_string(field)),
         {:ok, upload} <- normalize_upload(upload) do
      put_upload(changeset, field, upload)
    else
      _ ->
        changeset
    end
  end

  @spec put_upload(Changeset.t(), atom(), Upload.t()) :: Changeset.t()
  def put_upload(changeset, field, %Upload{} = upload) do
    store = Upload.file_store()
    blob = Upload.Blob.changeset(%Upload.Blob{}, Map.from_struct(upload))

    Changeset.prepare_changes(changeset, fn changeset ->
      case FileStore.copy(store, upload.path, upload.key) do
        :ok ->
          Changeset.put_assoc(changeset, field, blob)

        :error ->
          Changeset.add_error(changeset, field, "upload failed")
      end
    end)
  end

  defp normalize_upload(%Upload{} = upload), do: {:ok, upload}
  defp normalize_upload(%Plug.Upload{} = upload), do: {:ok, Upload.from_plug(upload)}
  defp normalize_upload(_), do: :error
end
