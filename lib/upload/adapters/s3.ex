if Code.ensure_compiled?(ExAws) do
  defmodule Upload.Adapters.S3 do
    use Upload.Adapter
    alias Upload.Config

    @doc """
    The bucket that was configured.

    ## Examples

        iex> Upload.Adapters.S3.bucket
        "my_bucket_name"

    """
    def bucket, do: Config.fetch!(__MODULE__, :bucket)

    @doc """
    The base URL that all resources are hosted on.

    ## Examples

        iex> Upload.Adapters.S3.uri
        "https://my_bucket_name.s3.amazonaws.com"

    """
    def uri do
      Config.get(__MODULE__, :uri, "https://#{bucket()}.s3.amazonaws.com")
    end

    @impl true
    def get_url(key) do
      uri()
      |> URI.merge(key)
      |> URI.to_string()
    end

    @impl true
    def transfer(%Upload{key: key, path: path} = upload) do
      with {:ok, data} <- File.read(path),
           {:ok, _} <- put_object(key, data) do
        {:ok, %Upload{upload | status: :transferred}}
      else
        _ ->
          {:error, "failed to transfer file"}
      end
    end

    defp put_object(key, data) do
      bucket()
      |> ExAws.S3.put_object(key, data)
      |> ExAws.request()
    end
  end
end
