if Code.ensure_compiled?(GoogleApi.Storage) do
  defmodule Upload.Adapters.GCS do
    use Upload.Adapter

    @scope "https://www.googleapis.com/auth/devstorage.read_write"

    @doc """
    The bucket that was configured.

    ## Examples

        iex> Upload.Adapters.GCS.bucket()
        "my_bucket_name"

    """
    def bucket, do: Config.fetch!(__MODULE__, :bucket)

    @impl true
    def get_url(key) do
    end

    @impl true
    def transfer(%Upload{key: key, path: path} = upload) do
      with {:ok, %{token: token}} <- Goth.Token.for_scope(@scope),
           {:ok, _} <- put_object(token, key, path) do
        {:ok, %Upload{upload | status: :transferred}}
      else
        _ ->
          {:error, "failed to transfer file"}
      end
    end

    defp put_object(token, key, path) do
      token
      |> GoogleApi.Storage.V1.Connection.new()
      |> GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_simple(
        bucket,
        "multipart",
        %{name: key},
        path
      )
    end
  end
end
