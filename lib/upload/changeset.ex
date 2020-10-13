defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob
  alias Upload.Storage
  alias Upload.Utils

  @spec put_attachment(Changeset.t(), atom(), term()) :: Changeset.t()
  def put_attachment(%Changeset{} = changeset, field, value) do
    changeset
    |> Changeset.put_assoc(field, value)
    |> Changeset.prepare_changes(&purge!(&1, field))
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

  defp purge!(changeset, field) do
    changeset.data |> Map.get(field) |> do_purge!()
    changeset
  end

  defp do_purge!(%Blob{key: key}) when is_binary(key) do
    case Storage.delete(key) do
      :ok ->
        Utils.log(:info, "Deleted file from key: #{key}")

      {:error, reason} ->
        raise "Failed to delete key: #{key} (reason: #{reason})"
    end
  end

  defp do_purge!(_), do: nil
end
