defmodule Upload.Adapters.Local do
  use Upload.Adapter

  @config Application.get_env(:upload, __MODULE__, [])

  @doc """
  Path where files are stored. Defaults to `priv/static/uploads`.

  ## Examples

      iex> Upload.Adapters.Local.storage_path
      "priv/static/uploads"

  """
  def storage_path do
    get_config(@config, :storage_path, "priv/static/uploads")
  end

  @doc """
  The URL prefix for the file key.

  ## Examples

      iex> Upload.Adapters.Local.public_path
      "/uploads"

  """
  def public_path do
    get_config(@config, :public_path, "/uploads")
  end

  @impl true
  def get_url(key) do
    join_url(public_path(), key)
  end

  defp join_url(a, b) do
    String.trim_trailing(a, "/") <> "/" <> String.trim_leading(b, "/")
  end

  @impl true
  def transfer(%Upload{key: key, path: path} = upload) do
    filename  = Path.join(storage_path(), key)
    directory = Path.dirname(filename)

    with :ok <- File.mkdir_p(directory),
         :ok <- File.cp(path, filename),
         do: {:ok, %Upload{upload | status: :transferred}}
  end
end
