defmodule Upload.Ecto do
  def cast_upload(%Ecto.Changeset{params: params} = changeset, field, opts \\ []) do
    uploader = Keyword.get(opts, :uploader, Upload)

    if file = Map.get(params, Atom.to_string(field)) do
      case uploader.cast(file) do
        {:ok, upload} ->
          put_upload(changeset, field, upload, opts)

        {:error, _} ->
          add_error(changeset, field, "is invalid")
      end
    else
      changeset
    end
  end

  def put_upload(changeset, field, %Upload{status: :pending} = upload, opts \\ []) do
    uploader = Keyword.get(opts, :uploader, Upload)

    case uploader.transfer(upload) do
      {:ok, upload} ->
        put_upload(changeset, field, upload, opts)

      {:error, _} ->
        add_error(changeset, field, "failed to upload")
    end
  end
  def put_upload(changeset, field, %Upload{status: :completed, key: key}, _opts) do
    Ecto.Changeset.put_change(changeset, field, key)
  end
end
