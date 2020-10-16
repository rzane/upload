defmodule Upload.Router do
  use Plug.Router

  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Storage
  alias Upload.Verifier

  plug :match
  plug :dispatch, builder_opts()

  # TODO: Accept query parameter for disposition
  # TODO: Allow `get_public_url` instead of `get_signed_url`
  # TODO: Allow for expiration
  # TODO: Send content_type and disposition to the service

  get "/blobs/:signed_blob_id/*_filename" do
    with {:ok, blob_id} <- Verifier.verify_blob_id(conn, signed_blob_id),
         {:ok, blob} <- fetch_blob(blob_id, opts) do
      redirect(conn, blob.key)
    else
      :error -> not_found(conn)
    end
  end

  get "/variants/:signed_blob_id/:signed_transforms/*_filename" do
    with {:ok, blob_id} <- Verifier.verify_blob_id(conn, signed_blob_id),
         {:ok, transforms} <- Verifier.verify_transforms(conn, signed_transforms),
         {:ok, blob} <- fetch_blob(blob_id, opts),
         variant <- Variant.new(conn, blob, transforms),
         :ok <- process_variant(variant) do
      redirect(conn, variant.key)
    else
      :error -> not_found(conn)
    end
  end

  defp fetch_blob(blob_id, opts) do
    case Keyword.fetch(opts, :repo) do
      {:ok, repo} ->
        case repo.get(Blob, blob_id) do
          nil -> :error
          blob -> {:ok, blob}
        end

      :error ->
        raise "You need to pass a repo to `Upload.Router`"
    end
  end

  defp process_variant(variant) do
    with {:error, reason} <- Variant.process(variant) do
      raise "Failed to transform key: #{variant.blob.key} (reason: #{inspect(reason)})"
    end
  end

  defp redirect(conn, key) do
    case Storage.get_signed_url(key) do
      {:ok, url} ->
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, reason} ->
        raise "Failed to generate URL for key: #{key} (reason: #{inspect(reason)})"
    end
  end

  defp not_found(conn) do
    send_resp(conn, 404, "")
  end
end
