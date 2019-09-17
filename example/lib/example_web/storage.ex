defmodule ExampleWeb.Storage do
  use Plug.Router

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
        Phoenix.Controller.redirect(conn, external: url)

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
      Phoenix.Controller.redirect(conn, external: url)
    else
      error ->
        IO.inspect(error)
        send_resp(conn, 400, "Bad Request")
    end
  end
end
