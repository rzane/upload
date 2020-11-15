defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  alias Upload.Stat
  alias Upload.Blob

  def stat(path) when is_binary(path) do
    Stat.stat(path)
  end

  def stat(%Plug.Upload{path: path} = upload) do
    with {:ok, stat} <- Stat.stat(path) do
      stat =
        stat
        |> Stat.put(:filename, upload.filename)
        |> Stat.put(:content_type, upload.content_type)

      {:ok, stat}
    end
  end

  def stat!(path) do
    case stat(path) do
      {:ok, stat} ->
        stat

      {:error, reason} when is_atom(reason) ->
        raise File.Error, path: path, reason: reason, action: "read file stats"

      {:error, exception} when is_struct(exception) ->
        raise exception
    end
  end

  def change_blob do
    Blob.changeset(%Blob{})
  end

  def change_blob(%Blob{} = blob) do
    Blob.changeset(blob)
  end

  def change_blob(%Stat{} = stat) do
    Blob.changeset(%Blob{}, Map.from_struct(stat))
  end

  def change_blob(attrs) when is_map(attrs) do
    Blob.changeset(%Blob{}, attrs)
  end

  def change_blob(%Blob{} = blob, %Stat{} = stat) do
    Blob.changeset(blob, Map.from_struct(stat))
  end

  def change_blob(%Blob{} = blob, attrs) when is_map(attrs) do
    Blob.changeset(blob, attrs)
  end
end
