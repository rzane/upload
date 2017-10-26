defmodule Upload.Adapters.S3 do
  use Upload.Adapter

  @config Application.get_env(:upload, __MODULE__, [])

  @doc """
  The bucket that was configured.

  ## Examples

      iex> Upload.Adapters.S3.bucket
      "my_bucket_name"

  """
  def bucket, do: fetch_config!(@config, :bucket)

  @doc """
  The base URL that all resources are hosted on.

      iex> Upload.Adapters.S3.uri
      "http://my_bucket_name.s3.amazonaws.com"
  """
  def uri do
    get_config(@config, :uri, "http://#{bucket()}.s3.amazonaws.com")
  end

  @impl true
  def get_url(key) do
    join_url(uri(), key)
  end

  @impl true
  def transfer(%Upload{key: key, path: path} = upload) do
    with {:ok, data} <- File.read(path),
         {:ok, _}    <- put_object(key, data),
         do: {:ok, %Upload{upload | status: :completed}}
  end

  defp put_object(key, data) do
    bucket()
    |> ExAws.S3.put_object(key, data)
    |> ExAws.request
  end
end
