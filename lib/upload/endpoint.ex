defmodule Upload.Endpoint do
  use Plug.Router

  require Logger

  plug :match
  plug :dispatch

  # TODO: There are issues here...
  get "/disk/*key" do
    key = Enum.join(key, "/")
    store = Upload.Config.file_store()

    case FileStore.Adapters.Disk.get_path(store, key) do
      {:ok, path} ->
        send_file(conn, 200, path)

      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  # TODO: Signed key?
  # TODO: Redirect with pure plug?
  get "/blobs/:key" do
    store = Upload.Config.file_store()

    case FileStore.get_signed_url(store, key) do
      {:ok, url} ->
        redirect(conn, url)

      {:error, _} ->
        send_resp(conn, 400, "Bad Request")
    end
  end

  get "/variant/:key/:variation_key" do
    blob = %Upload.Blob{key: key}
    store = Upload.Config.file_store()

    with {:ok, variant} <- Upload.Variant.decode(blob, variation_key),
         {:ok, variant} <- Upload.Variant.process(variant),
         {:ok, url} <- FileStore.get_signed_url(store, variant.key) do
      redirect(conn, url)
    else
      :error ->
        Logger.error("Invalid key")
        send_resp(conn, 404, "Not Found")

      {:error, reason} ->
        Logger.error("Failed to send variant (reason: #{reason})")
        send_resp(conn, 400, "Bad Request")
    end
  end

  defp redirect(conn, url) do
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
  end
end
