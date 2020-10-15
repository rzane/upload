defmodule Upload.Multi do
  alias Ecto.Multi
  alias Ecto.Association.NotLoaded

  alias Upload.Blob
  alias Upload.Storage
  alias Upload.Utils

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
      case Storage.delete(key) do
        :ok ->
          Utils.info("Deleted file from key: #{key}")
          {:ok, nil}

        {:error, reason} ->
          Utils.error("Failed to delete file from key: #{key}")
          {:error, reason}
      end
    end)
  end

  defp do_upload(nil), do: {:ok, nil}
  defp do_upload(%NotLoaded{}), do: {:ok, nil}
  defp do_upload(%Blob{path: nil}), do: {:ok, nil}

  defp do_upload(%Blob{path: path, key: key, checksum: checksum}) do
    case Storage.upload(path, key) do
      :ok ->
        Utils.info("Uploaded file to key: #{key} (checksum: #{checksum})")
        {:ok, nil}

      {:error, reason} ->
        Utils.error("Failed to load file to key: #{key} (reason: #{inspect(reason)})")
        {:error, reason}
    end
  end
end
