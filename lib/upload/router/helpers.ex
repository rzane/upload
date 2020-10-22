defmodule Upload.Router.Helpers do
  alias Upload.Key
  alias Upload.Blob
  alias Upload.Variant

  @type conn :: Plug.Conn.t() | URI.t()
  @type stored :: Blob.t() | Variant.t()
  @type storage_path_opts :: [{:base, binary}]

  defmacro __using__(config) do
    quote location: :keep do
      def storage_path(conn, blob, opts \\ []) do
        opts = Keyword.merge(unquote(config), opts)
        unquote(__MODULE__).storage_path(conn, blob, opts)
      end

      def storage_url(conn, blob, opts \\ []) do
        opts = Keyword.merge(unquote(config), opts)
        unquote(__MODULE__).storage_path(conn, blob, opts)
      end
    end
  end

  @spec storage_path(conn, stored, storage_path_opts) :: binary
  def storage_path(conn, stored, opts \\ [])

  def storage_path(_conn, %Blob{} = blob, opts) do
    {base, opts} = Keyword.pop(opts, :base, "/storage")

    base
    |> clean_path()
    |> append_path("blobs")
    |> append_path(Key.sign(blob))
    |> append_path(blob.filename)
    |> append_query(opts)
  end

  def storage_path(_conn, %Variant{blob: blob} = variant, opts) do
    {base, opts} = Keyword.pop(opts, :base, "/storage")
    {signed_blob, signed_transforms} = Key.sign(variant)

    base
    |> clean_path()
    |> append_path("variants")
    |> append_path(signed_blob)
    |> append_path(signed_transforms)
    |> append_path(blob.filename)
    |> append_query(opts)
  end

  @spec storage_url(conn, stored, storage_path_opts) :: binary
  def storage_url(conn, stored, opts) do
    conn
    |> build_uri()
    |> URI.merge(storage_path(conn, stored, opts))
    |> URI.to_string()
  end

  defp clean_path(path), do: String.trim_trailing(path, "/")
  defp append_path(path, other_path), do: path <> "/" <> other_path
  defp append_query(path, []), do: path
  defp append_query(path, query), do: path <> "?" <> URI.encode_query(query)

  defp build_uri(%URI{} = uri), do: uri

  defp build_uri(%Plug.Conn{} = conn) do
    %URI{scheme: to_string(conn.scheme), host: conn.host, port: conn.port}
  end
end
