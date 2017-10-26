defmodule Upload.Ecto do
  @doc """
  Casts an upload in the params under the given key, uploads it, and assigns it to the field.
  """
  def cast_upload(%Ecto.Changeset{params: params} = changeset, field, opts \\ []) do
    cast = Keyword.get(opts, :with, &Upload.cast/2)

    if file = Map.get(params, Atom.to_string(field)) do
      case cast.(file, Keyword.delete(opts, :with)) do
        {:ok, upload} ->
          put_upload(changeset, field, upload)

        {:error, message} when is_binary(message) ->
          Ecto.Changeset.add_error(changeset, field, message)
      end
    else
      changeset
    end
  end

  @doc """
  Add the Upload's key to the changeset for the given field.

  If the file hasn't been uploaded yet, it will be.
  """
  def put_upload(changeset, field, %Upload{status: :pending} = upload) do
    case Upload.transfer(upload) do
      {:ok, upload} ->
        put_upload(changeset, field, upload)

      {:error, _} ->
        Ecto.Changeset.add_error(changeset, field, "failed to upload")
    end
  end
  def put_upload(changeset, field, %Upload{status: :completed, key: key}) do
    Ecto.Changeset.put_change(changeset, field, key)
  end
end
