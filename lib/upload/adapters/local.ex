defmodule Upload.Adapters.Local do
  @moduledoc """
  An `Upload.Adapter` that saves files to disk.

  ### Configuration

      config :upload, Upload.Adapters.Local,
        base_url: "/uploads", # optional
        storage_path: "priv/static/uploads" # optional

  """

  use Upload.Adapter
  alias Upload.Config

  @doc """
  Path where files are stored. Defaults to `priv/static/uploads`.

  ## Examples

      iex> Upload.Adapters.Local.storage_path()
      "priv/static/uploads"

  """
  def storage_path do
    Config.get(__MODULE__, :storage_path, "priv/static/uploads")
  end

  @doc """
  The URL prefix for the file key.

  ## Examples

      iex> Upload.Adapters.Local.base_url()
      "/uploads"

  """
  def base_url do
    Config.get(__MODULE__, :base_url, "/uploads")
  end

  @impl true
  def get_url(key), do: join_url(base_url(), key)

  @impl true
  def get_signed_url(key, _opts), do: {:ok, get_url(key)}

  @impl true
  def transfer(%Upload{key: key, path: path} = upload) do
    filename = Path.join(storage_path(), key)
    directory = Path.dirname(filename)

    with :ok <- File.mkdir_p(directory),
         :ok <- File.cp(path, filename) do
      {:ok, %Upload{upload | status: :transferred}}
    else
      _ ->
        {:error, "failed to transfer file"}
    end
  end

  defp join_url(a, b) do
    String.trim_trailing(a, "/") <> "/" <> String.trim_leading(b, "/")
  end
end
