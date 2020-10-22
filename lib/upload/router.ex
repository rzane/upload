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
    case Key.verify(signed_blob, signed_transforms) do
      {:ok, variant} ->
        case Variant.ensure_exists(variant) do
          {:ok, key} ->
            redirect(conn, key)

          {:error, reason} ->
            log_error(reason)
            send_resp(conn, 400, "")
        end

      :error ->
        send_resp(conn, 400, "")
    end
  end

  defp redirect(conn, key) do
    case Storage.get_signed_url(key) do
      {:ok, url} ->
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, reason} ->
        log_error({:redirect, reason})
        send_resp(conn, 422, "")
    end
  end

  defp log_error(reason) do
    reason |> format_error() |> Utils.log(:error)
  end

  defp format_error({:upload, reason}),
    do: "Failed to upload the transformed image (reason: #{inspect(reason)})"

  defp format_error({:download, reason}),
    do: "Failed to download the original image (reason: #{inspect(reason)})"

  defp format_error({:transform, reason}),
    do: "Failed to apply transformations to the image (reason: #{inspect(reason)})"

  defp format_error({:cleanup, reason}),
    do: "Failed to cleanup temporary files (reason: #{inspect(reason)})"

  defp format_error({:redirect, reason}),
    do: "Failed to generate a signed URL (reason: #{inspect(reason)})"
end
