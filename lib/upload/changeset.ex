defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob
  alias Upload.Key
  alias Upload.Storage
  alias Upload.Utils

  @spec put_attachment(Changeset.t(), atom(), term()) :: Changeset.t()
  def put_attachment(%Changeset{} = changeset, field, attachment) do
    changeset
    |> Changeset.put_assoc(field, attachment)
    |> Changeset.prepare_changes(fn changeset ->
      blob = Changeset.get_change(changeset, field)
      old_blob = Map.get(changeset.data, field)

      case upload_blob(blob) do
        {:ok, blob} ->
          purge_blob(old_blob)
          Changeset.put_change(changeset, field, blob)

        {:error, reason} ->
          Changeset.add_error(changeset, field, "upload failed", reason: reason)
      end
    end)
  end

  @spec cast_attachment(Changeset.t(), atom(), keyword()) :: Changeset.t()
  def cast_attachment(%Changeset{} = changeset, field, opts \\ []) do
    invalid_message = Keyword.get(opts, :invalid_message, "is invalid")

    case Map.fetch(changeset.params, to_string(field)) do
      {:ok, %{__struct__: Plug.Upload} = plug_upload} ->
        put_attachment(changeset, field, Blob.from_plug(plug_upload))

      {:ok, nil} ->
        put_attachment(changeset, field, nil)

      {:ok, _other} ->
        Changeset.add_error(changeset, field, invalid_message)

      :error ->
        changeset
    end
  end

  defp upload_blob(%Changeset{changes: %{path: path}} = changeset) when is_binary(path) do
    with {:ok, stat} <- File.stat(path),
         {:ok, checksum} <- FileStore.Stat.checksum_file(path),
         key <- Key.generate(),
         :ok <- do_upload(path, key, checksum) do
      changeset
      |> Changeset.put_change(:key, key)
      |> Changeset.put_change(:byte_size, stat.size)
      |> Changeset.put_change(:checksum, checksum)
      |> ok()
    end
  end

  defp upload_blob(value), do: {:ok, value}

  defp do_upload(path, key, checksum) do
    case Storage.upload(path, key) do
      :ok ->
        Utils.log(:info, "Uploaded file to key: #{key} (checksum: #{checksum})")
        :ok

      {:error, reason} ->
        Utils.log(:error, "Failed to upload file to key: #{key} (reason: #{inspect(reason)})")
        {:error, reason}
    end
  end

  defp purge_blob(%Blob{key: key}) when is_binary(key) do
    case Storage.delete(key) do
      :ok ->
        Utils.log(:info, "Deleted file from key: #{key}")

      {:error, reason} ->
        Utils.log(:error, "Failed to delete file from key: #{key} (reason: #{inspect(reason)}")
    end
  end

  defp purge_blob(_), do: nil

  defp ok(value), do: {:ok, value}
end
