if Code.ensure_compiled?(GoogleApi.Storage.V1.Connection) do
  defmodule Upload.Adapters.GCS do
    use Upload.Adapter
    alias Upload.Config

    defmodule Anonymous do
      def call do
        {:ok, GoogleApi.Storage.V1.Connection.new()}
      end
    end

    defmodule Authenticated do
      @scope "https://www.googleapis.com/auth/devstorage.read_write"

      def call do
        case Goth.Token.for_scope(@scope) do
          {:ok, %{token: token}} ->
            {:ok, GoogleApi.Storage.V1.Connection.new(token)}

          _ ->
            :error
        end
      end
    end

    @doc """
    The bucket that was configured.

    ## Examples

        iex> Upload.Adapters.GCS.bucket()
        "my_bucket_name"

    """
    def bucket, do: Config.fetch!(__MODULE__, :bucket)

    @doc """
    The base URL that all resources are hosted on.

    ## Examples

        iex> Upload.Adapters.GCS.uri()
        "https://storage.googleapis.com/my_bucket_name/"

    """
    def uri do
      Config.get(__MODULE__, :uri, "https://storage.googleapis.com/#{bucket()}/")
    end

    @doc """
    Builds a connection to the API.
    """
    def build_connection do
      builder = Config.get(__MODULE__, :connection, Authenticated)
      builder.call()
    end

    @impl true
    def transfer(%Upload{key: key, path: path} = upload) do
      with {:ok, conn} <- build_connection(),
           {:ok, _} <- put_object(conn, key, path) do
        {:ok, %Upload{upload | status: :transferred}}
      else
        _error ->
          {:error, "failed to transfer file"}
      end
    end

    @impl true
    def get_url(key) do
      uri()
      |> URI.merge(key)
      |> URI.to_string()
    end

    defp put_object(conn, key, path) do
      GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_simple(
        conn,
        bucket(),
        "multipart",
        %{name: key},
        path
      )
    end
  end
end
