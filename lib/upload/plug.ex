defmodule Upload.Endpoint do
  use Plug.Router

  require Logger

  alias Upload.Key
  alias Upload.Config
  alias Upload.Variant
  alias FileStore.Adapters.Disk

  plug(:match)
  plug(:dispatch)

  # TODO: Support filename
  # TODO: Use an encoded/signed key?
  get "/disk/*key" do
    key = Enum.join(key, "/")
    store = Config.file_store()

    case Disk.get_path(store, key) do
      {:ok, path} ->
        send_file(conn, 200, path)

      _error ->
        send_resp(conn, 404, "Not Found")
    end
  end

  # TODO: Disposition query parameter
  # TODO: Rails uses ID for blobs instead of key. Why?
  get "/blobs/:signed_blob_key/*_filename" do
    with {:ok, blob_key} <- Key.verify(signed_blob_key, :blob),
         {:ok, url} <- Upload.get_signed_url(blob_key) do
      redirect(conn, url)
    else
      :error ->
        send_resp(conn, 400, "Bad Request")

      {:error, _} ->
        send_resp(conn, 400, "Bad Request")
    end
  end

  # TODO: Rails uses ID for blobs instead of key. Why?
  # TODO: Consider removing `Variant.decode` and just `Key.verify` here.
  get "/variants/:signed_blob_key/:variation_key/*_filename" do
    with {:ok, blob_key} <- Key.verify(signed_blob_key, :blob),
         {:ok, variant} <- Variant.decode(blob_key, variation_key),
         {:ok, variant} <- Variant.process(variant),
         {:ok, url} <- Upload.get_signed_url(variant.key) do
      redirect(conn, url)
    else
      :error ->
        Logger.error("Failed to send variant")
        send_resp(conn, 400, "Bad Request")

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
