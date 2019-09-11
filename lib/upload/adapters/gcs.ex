if Code.ensure_compiled?(GoogleApi.Storage.V1.Connection) do
  defmodule Upload.Adapters.GCS do
    use Upload.Adapter
    alias Upload.Config

    alias Upload.Adapters.GCS.Authenticated
    alias Upload.Adapters.GCS.Signer

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

    @impl true
    def get_signed_url(key, opts) do
      signer = Config.get(__MODULE__, :signer, Signer)
      signer.sign(bucket(), key, opts)
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

  defmodule Upload.Adapters.GCS.Anonymous do
    def call do
      {:ok, GoogleApi.Storage.V1.Connection.new()}
    end
  end

  defmodule Upload.Adapters.GCS.Authenticated do
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

  defmodule Upload.Adapters.GCS.Signer do
    @base_url "https://storage.googleapis.com"
    @otp_greater_21 :erlang.system_info(:otp_release) >= '21'

    def sign(bucket, key, opts \\ []) do
      path = "/#{bucket}/#{URI.encode(key)}"
      verb = Keyword.get(opts, :verb, "GET")
      account = Keyword.get(opts, :account, :default)
      content_type = Keyword.get(opts, :content_type, "")
      expires_in = Keyword.get(opts, :expires_in, 3600)
      md5_digest = Keyword.get(opts, :md5_digest, "")

      with {:ok, client_email} <- get_config(account, "client_email"),
            {:ok, private_key} <- get_config(account, "private_key") do
        signature =
          [verb, md5_digest, content_type, expires_in, path]
          |> Enum.join("\n")
          |> :public_key.sign(:sha256, decode_private_key(private_key))
          |> Base.encode64()

        query = %{
          "GoogleAccessId" => client_email,
          "Expires" => expires_in,
          "Signature" => signature
        }

        {:ok, Enum.join([@base_url, path, "?", URI.encode_query(query)])}
      end
    end

    defp get_config(account, key) do
      case Goth.Config.get(account, key) do
        {:ok, value} ->
          {:ok, value}

        :error ->
          {:error, "failed to retrieve configuration"}
      end
    end

    defp decode_private_key(private_key) do
      private_key
      |> :public_key.pem_decode()
      |> (fn [x] -> x end).()
      |> :public_key.pem_entry_decode()
      |> normalize_private_key
    end

    defp normalize_private_key(private_key) do
      if @otp_greater_21 do
        private_key
      else
        private_key
        |> elem(3)
        |> (fn pk -> :public_key.der_decode(:RSAPrivateKey, pk) end).()
      end
    end
  end
end
