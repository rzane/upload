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

  @spec validate_content_type(Changeset.t(), atom(), list(), keyword()) :: Changeset.t()
  def validate_content_type(changeset, field, types, opts \\ []) do
    validate_nested(
      changeset,
      field,
      &Changeset.validate_inclusion(&1, :content_type, types, opts)
    )
  end

  defp validate_nested(changeset, field, fun) do
    case Changeset.fetch_change(changeset, field) do
      {:ok, %Changeset{} = nested} ->
        Changeset.put_change(changeset, field, fun.(nested))

      _ ->
        changeset
    end
  end
end
