defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob

  @spec put_attachment(Changeset.t(), atom(), term()) :: Changeset.t()
  def put_attachment(%Changeset{} = changeset, field, attachment) do
    Changeset.put_assoc(changeset, field, attachment)
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
end
