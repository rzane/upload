if Code.ensure_compiled?(ExAws.S3) do
  defmodule Upload.Adapters.S3 do
    use Upload.Adapter
    alias Upload.Config

    @doc """
    The bucket that was configured.

    ## Examples

        iex> Upload.Adapters.S3.bucket()
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
    def get_signed_url(key) do
      :s3
      |> ExAws.Config.new()
      |> ExAws.S3.presigned_url(:get, bucket(), key)
    end

    @impl true
    def transfer(%Upload{key: key, path: path} = upload) do
      case put_object(key, path) do
        {:ok, _} ->
          {:ok, %Upload{upload | status: :transferred}}

        _ ->
          {:error, "failed to transfer file"}
      end
    end

    defp put_object(key, path) do
      path
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(bucket(), key)
      |> ExAws.request()
    end
  end
end
