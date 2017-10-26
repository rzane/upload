defmodule Upload.Ecto do
  @doc """
  Casts an upload in the params under the given key, uploads it, and assigns it to the field.

  ## Examples

      iex> %User{}
      ...> |> User.changeset(%{"picture" => %Plug.Upload{filename: "me.png", path: "/path/to/me.png"}})
      ...> |> Upload.Ecto.cast_upload(:picture)
      ...> |> Ecto.Changeset.apply_changes()
      %User{picture: "91ce276a-1c76-500b-add7-e4e13bba4c07.png"}

      iex> %User{}
      ...> |> User.changeset(%{"picture" => "/path/to/me.png"})
      ...> |> Upload.Ecto.cast_upload(:picture, with: &Upload.cast_path/2)
      ...> |> Ecto.Changeset.apply_changes()
      %User{picture: "91ce276a-1c76-500b-add7-e4e13bba4c07.png"}

      iex> %User{}
      ...> |> User.changeset(%{"picture" => %Plug.Upload{filename: "me.png", path: "/path/to/me.png"}})
      ...> |> Upload.Ecto.cast_upload(:picture, prefix: ["pictures"])
      ...> |> Ecto.Changeset.apply_changes()
      %User{picture: "pictures/91ce276a-1c76-500b-add7-e4e13bba4c07.png"}

  """
  def cast_upload(changeset, field, opts \\ []) do
    {cast, opts} = Keyword.pop(opts, :with, &Upload.cast/2)

    if value = Map.get(changeset.params, Atom.to_string(field)) do
      case cast.(value, opts) do
        {:ok, upload} ->
          put_upload(changeset, field, upload)

        {:error, :invalid} ->
          changeset

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
    Ecto.Changeset.prepare_changes changeset, fn changeset ->
      case Upload.transfer(upload) do
        {:ok, upload} ->
          put_upload(changeset, field, upload)

        {:error, _} ->
          Ecto.Changeset.add_error(changeset, field, "failed to upload")
      end
    end
  end
  def put_upload(changeset, field, %Upload{status: :completed, key: key}) do
    Ecto.Changeset.put_change(changeset, field, key)
  end
end
