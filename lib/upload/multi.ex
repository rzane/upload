defmodule Upload.Multi do
  alias Ecto.Multi
  alias Ecto.Changeset
  alias Ecto.Association.BelongsTo
  alias Ecto.Association.NotLoaded

  alias Upload.Blob
  alias Upload.Storage

  def insert(multi, name, changeset_or_struct, opts \\ []) do
    multi = Multi.insert(multi, name, changeset_or_struct, opts)

    changeset_or_struct
    |> get_blob_names()
    |> Enum.reduce(multi, &upload(&2, name, &1))
  end

  def update(multi, name, changeset, opts \\ []) do
    multi = Multi.update(multi, name, changeset, opts)

    changeset
    |> get_blob_names()
    |> Enum.reduce(multi, &upload(&1, name, &2))
  end

  def upload(multi, name, blob_name) do
    Multi.run(
      multi,
      {name, blob_name},
      fn _repo, %{^name => %{^blob_name => blob}} ->
        with :ok <- do_upload(blob), do: {:ok, blob}
      end
    )
  end

  defp do_upload(nil), do: :ok
  defp do_upload(%NotLoaded{}), do: :ok
  defp do_upload(%Blob{path: nil}), do: :ok
  defp do_upload(%Blob{path: path, key: key}), do: Storage.upload(path, key)

  def get_blob_names(%Changeset{data: data}), do: get_blob_names(data)
  def get_blob_names(%{__struct__: schema}), do: get_blob_names(schema)

  def get_blob_names(schema) when is_atom(schema) do
    for name <- schema.__schema__(:associations),
        assoc = schema.__schema__(:association, name),
        match?(%BelongsTo{related: Blob}, assoc),
        do: name
  end
end
