defmodule Upload.Changeset do
  import Ecto.Changeset

  @type changeset :: Ecto.t()
  @type field :: atom
  @type error :: binary | Changeset.error()
  @type validation :: (any -> [error])
  @type size :: {number, :byte | :kilobyte | :megabyte | :gigabyte | :terabyte}

  @type cast_opts :: [{:invalid_message, binary}]
  @type size_opts :: [{:less_than, size} | {:message, binary}]
  @type type_opts :: [{:allow, [binary]} | {:forbid, [binary]} | {:message, binary}]

  @unit_conversions %{
    byte: 1,
    kilobyte: 1.0e3,
    megabyte: 1.0e6,
    gigabyte: 1.0e9,
    terabyte: 1.0e12
  }

  @spec put_attachment(changeset(), field(), Path.t()) :: changeset()
  def put_attachment(changeset, field, path) when is_binary(path) do
    put_attachment(changeset, field, Upload.stat!(path))
  end

  @spec put_attachment(changeset(), field(), Plug.Upload.t()) :: changeset()
  def put_attachment(changeset, field, %Plug.Upload{} = upload) do
    put_attachment(changeset, field, Upload.stat!(upload))
  end

  @spec put_attachment(changeset(), field(), Upload.Stat.t()) :: changeset()
  def put_attachment(changeset, field, %Upload.Stat{} = stat) do
    put_assoc(changeset, field, Upload.change_blob(stat))
  end

  @spec put_attachment(changeset(), field(), Ecto.Changeset.t()) :: changeset()
  def put_attachment(changeset, field, %Ecto.Changeset{} = blob_changeset) do
    put_assoc(changeset, field, blob_changeset)
  end

  @spec put_attachment(changeset(), field(), Upload.Blob.t()) :: changeset()
  def put_attachment(changeset, field, %Upload.Blob{} = blob) do
    put_assoc(changeset, field, blob)
  end

  @spec cast_attachment(changeset(), field(), cast_opts()) :: changeset()
  def cast_attachment(changeset, field, opts \\ []) do
    case Map.fetch(changeset.params, to_string(field)) do
      {:ok, %Plug.Upload{} = upload} ->
        put_attachment(changeset, field, upload)

      {:ok, nil} ->
        if Keyword.get(opts, :required, false) do
          message = Keyword.get(opts, :required_message, "can't be blank")
          meta = [validation: :required]
          add_error(changeset, field, message, meta)
        else
          put_assoc(changeset, field, nil)
        end

      {:ok, _other} ->
        message = Keyword.get(opts, :invalid_message, "is invalid")
        meta = [validation: :assoc, type: :map]
        add_error(changeset, field, message, meta)

      :error ->
        changeset
    end
  end

  @spec validate_attachment(changeset, field, field, validation) :: changeset
  def validate_attachment(changeset, field, blob_field, validation) do
    validate_change(changeset, field, fn _, blob_changeset ->
      case get_change(blob_changeset, blob_field) do
        nil -> []
        value -> [{field, validation.(value)}]
      end
    end)
  end

  @spec validate_attachment_type(changeset, field, type_opts) :: changeset
  def validate_attachment_type(changeset, field, opts) do
    {message, opts} = Keyword.pop(opts, :message, "is not a supported file type")

    validate_attachment(changeset, field, :content_type, fn type ->
      Enum.flat_map(opts, fn
        {:allow, types} ->
          if type in types, do: [], else: [{message, allowed: types}]

        {:forbid, types} ->
          if type in types, do: [{message, forbidden: types}], else: []

        {key, _} ->
          raise ArgumentError, """
          unknown option #{inspect(key)} given to validate_attachment_type/3

          The supported options are `:message`, `:allow` and `:forbid`.
          """
      end)
    end)
  end

  @spec validate_attachment_size(changeset, field, size_opts) :: changeset
  def validate_attachment_size(changeset, field, opts) do
    size = {number, unit} = Keyword.fetch!(opts, :smaller_than)
    message = Keyword.get(opts, :message, "must be smaller than %{number} %{unit}(s)")
    max_byte_size = to_bytes(size)

    validate_attachment(changeset, field, :byte_size, fn
      byte_size when byte_size < max_byte_size -> []
      _ -> [{message, number: number, unit: unit}]
    end)
  end

  for {unit, multiplier} <- @unit_conversions do
    defp to_bytes({n, unquote(unit)}), do: n * unquote(multiplier)
  end
end
