defmodule Upload.Changeset do
  @doc """
  Apply an upload to an changeset.
  """

  alias Upload.Analyzer
  alias Upload.Blob
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
    Changeset.prepare_changes(changeset, &do_put_upload(&1, field, upload))
  end

  defp do_put_upload(changeset, field, %Upload{} = upload) do
    store = Upload.file_store()

    with {:ok, upload} <- Analyzer.analyze(upload),
         :ok <- FileStore.copy(store, upload.path, upload.key) do
      Changeset.put_assoc(changeset, field, change_blob(upload))
    else
      {:error, reason} ->
        Changeset.add_error(changeset, field, "upload failed", reason: reason)

      :error ->
        Changeset.add_error(changeset, field, "upload failed", reason: "transfer failed")
    end
  end

  defp change_blob(upload), do: Blob.changeset(%Blob{}, Map.from_struct(upload))

  defp normalize_upload(%Upload{} = upload), do: {:ok, upload}
  defp normalize_upload(%Plug.Upload{} = upload), do: {:ok, Upload.from_plug(upload)}
  defp normalize_upload(_), do: :error
end
