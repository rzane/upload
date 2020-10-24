defmodule Upload.Changeset do
  alias Ecto.Changeset
  alias Upload.Blob

  @type cast_attachment_opts :: [{:invalid_message, binary}]

  @spec cast_attachment(Changeset.t(), atom, cast_attachment_opts) :: Changeset.t()
  def cast_attachment(%Changeset{} = changeset, field, opts \\ []) do
    invalid_message = Keyword.get(opts, :invalid_message, "is invalid")

    case Map.fetch(changeset.params, to_string(field)) do
      {:ok, %{__struct__: Plug.Upload} = plug_upload} ->
        Changeset.put_assoc(changeset, field, Blob.from_plug(plug_upload))

      {:ok, nil} ->
        Changeset.put_assoc(changeset, field, nil)

      {:ok, _other} ->
        Changeset.add_error(changeset, field, invalid_message)

      :error ->
        changeset
    end
  end

  @spec validate_attachment(Changeset.t(), atom(), (Changeset.t() -> Changeset.t())) ::
          Changeset.t()
  def validate_attachment(changeset, field, fun) when is_function(fun) do
    case Changeset.get_change(changeset, field) do
      %Changeset{} = blob_changeset ->
        Changeset.put_change(changeset, field, fun.(blob_changeset))

      _ ->
        changeset
    end
  end

  @spec validate_content_type(Changeset.t(), atom, Enum.t(), keyword) :: Changeset.t()
  def validate_content_type(changeset, field, types, opts \\ []) do
    validate_attachment(changeset, field, fn blob_changeset ->
      Changeset.validate_inclusion(blob_changeset, :content_type, types, opts)
    end)
  end

  @spec validate_byte_size(Changeset.t(), atom, keyword) :: Changeset.t()
  def validate_byte_size(changeset, field, opts \\ []) do
    opts = Enum.map(opts, fn {k, v} -> {k, convert_units(v)} end)

    validate_attachment(changeset, field, fn blob_changeset ->
      Changeset.validate_number(blob_changeset, :byte_size, opts)
    end)
  end

  defp convert_units({n, :byte}), do: n
  defp convert_units({n, :kilobyte}), do: n * 1.0e3
  defp convert_units({n, :megabyte}), do: n * 1.0e6
  defp convert_units({n, :gigabyte}), do: n * 1.0e9
  defp convert_units({n, :terabyte}), do: n * 1.0e12
  defp convert_units(value), do: value
end
