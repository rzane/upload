defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob

  @type cast_attachment_opts :: [{:invalid_message, binary}]

  @spec put_attachment(Changeset.t(), atom, term) :: Changeset.t()
  def put_attachment(%Changeset{} = changeset, field, attachment) do
    Changeset.put_assoc(changeset, field, attachment)
  end

  @spec cast_attachment(Changeset.t(), atom, cast_attachment_opts) :: Changeset.t()
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

  @spec validate_attachment(Changeset.t(), atom(), (Changeset.t() -> Changeset.t())) :: Changeset.t()
  def validate_attachment(changeset, field, fun) when is_function(fun) do
    case Changeset.get_change(changeset, field) do
      %Changeset{} = blob_changeset ->
        Changeset.put_change(changeset, field, fun.(blob_changeset))

      _ ->
        changeset
    end
  end
end
