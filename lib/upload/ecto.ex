defmodule Upload.Ecto do
  @doc """
  Casts an upload in the params under the given key, uploads it, and assigns it to the field.
  """
  def cast_upload(changeset, field, opts \\ []) do
    do_cast(:cast, changeset, field, opts)
  end

  @doc """
  Casts a path in the params under a given key, uploads it, and assigns it to the field.
  """
  def cast_upload_path(changeset, field, opts \\ []) do
    do_cast(:cast_path, changeset, field, opts)
  end

  defp do_cast(action, changeset, field, opts) do
    value = Map.get(changeset.params, Atom.to_string(field))
    {uploader, cast_opts} = Keyword.pop(opts, :with, Upload)

    case apply(uploader, action, [value, cast_opts]) do
      {:ok, upload} ->
        put_upload(changeset, field, upload, opts)

      {:error, :not_uploadable} ->
        changeset

      {:error, message} when is_binary(message) ->
        Ecto.Changeset.add_error(changeset, field, message)

      other ->
        raise """
        Expected #{inspect uploader}.#{action} to return one of the following:

          {:ok, %Upload{}}          - Casting was successful
          {:error, :not_uploadable} - Unable to cast value, don't upload it.
          {:error, "error message"} - Validation error

        Instead, it returned:

          #{inspect other}
        """
    end
  end

  @doc """
  Add the Upload's key to the changeset for the given field.

  If the file hasn't been uploaded yet, it will be.
  """
  def put_upload(changeset, field, upload, opts \\ [])
  def put_upload(changeset, field, %Upload{status: :pending} = upload, opts) do
    uploader = Keyword.get(opts, :with, Upload)

    Ecto.Changeset.prepare_changes changeset, fn changeset ->
      case uploader.transfer(upload) do
        {:ok, upload} ->
          put_upload(changeset, field, upload)

        {:error, message} when is_binary(message) ->
          Ecto.Changeset.add_error(changeset, field, message)

        {:error, _} ->
          Ecto.Changeset.add_error(changeset, field, "failed to upload")
      end
    end
  end
  def put_upload(changeset, field, %Upload{status: :transferred, key: key}, _opts) do
    Ecto.Changeset.put_change(changeset, field, key)
  end
end
