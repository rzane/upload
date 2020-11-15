defmodule Upload.Router do
  use Plug.Router

  alias Upload.Key
  alias Upload.Utils
  alias Upload.Variant
  alias Upload.Storage

  plug :match
  plug :dispatch

  # TODO: Accept query parameter for disposition
  # TODO: Allow `get_public_url` instead of `get_signed_url`
  # TODO: Allow for expiration
  # TODO: Send content_type and disposition to the service

  get "/blobs/:signed_blob/*_filename" do
    case Key.verify(signed_blob) do
      {:ok, blob} ->
        redirect(conn, blob.key)

      :error ->
        send_resp(conn, 400, "")
    end
  end

  get "/variants/:signed_blob/:signed_transforms/*_filename" do
    with {:ok, variant} <- Key.verify(signed_blob, signed_transforms),
         {:ok, key} <- Variant.ensure_exists(variant) do
      redirect(conn, key)
    else
      :error ->
        send_resp(conn, 400, "")

      {:error, error} ->
        error
        |> Exception.message()
        |> Utils.log(:error)

        send_resp(conn, 422, "")
    end
  end

  defp redirect(conn, key) do
    case Storage.get_signed_url(key) do
      {:ok, url} ->
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, reason} ->
        Utils.log("Failed to generate a signed URL: #{inspect(reason)}", :error)
        send_resp(conn, 422, "")
    end
  end
end
