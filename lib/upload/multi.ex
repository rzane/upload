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
        blob |> do_upload() |> to_result()
      end
    )
  end

  defp do_upload(nil), do: :ok
  defp do_upload(%NotLoaded{}), do: :ok
  defp do_upload(%Blob{path: nil}), do: :ok
  defp do_upload(%Blob{path: path, key: key}), do: Storage.upload(path, key)

  defp to_result(:ok), do: {:ok, nil}
  defp to_result(other), do: other
end
