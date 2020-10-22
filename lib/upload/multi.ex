defmodule Upload.Multi do
  alias Ecto.Multi
  alias Ecto.Association.NotLoaded

  alias Upload.Blob
  alias Upload.Storage

  def upload(multi, name, blob_name) do
    Multi.run(
      multi,
      {name, blob_name},
      fn _repo, %{^name => %{^blob_name => blob}} ->
        do_upload(blob)
      end
    )
  end

  def purge(multi, _name, nil), do: multi

  def purge(multi, name, %Blob{key: key}) do
    Multi.run(multi, name, fn _, _ ->
      with :ok <- Storage.delete(key), do: {:ok, nil}
    end)
  end

  defp do_upload(nil), do: {:ok, nil}
  defp do_upload(%NotLoaded{}), do: {:ok, nil}
  defp do_upload(%Blob{path: nil}), do: {:ok, nil}

  defp do_upload(%Blob{path: path, key: key}) do
    with :ok <- Storage.upload(path, key), do: {:ok, nil}
  end
end
