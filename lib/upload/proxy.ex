defmodule Upload.Proxy do
  use Plug.Router

  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Storage
  alias Upload.Verifier

  plug :match
  plug :dispatch, builder_opts()

  # TODO: Accept query parameter for disposition
  # TODO: Allow `get_public_url`
  # TODO: Send content_type to `get_signed_url`

  get "/blobs/:signed_blob_id/*_filename" do
    repo = Keyword.fetch!(opts, :repo)

    case verify_blob(repo, signed_blob_id) do
      {:ok, blob} ->
        redirect(conn, blob.key)

      :error ->
        not_found(conn)
    end
  end

  get "/variants/:signed_blob_id/:signed_transforms/*_filename" do
    repo = Keyword.fetch!(opts, :repo)

    case verify_variant(repo, signed_blob_id, signed_transforms) do
      {:ok, variant} ->
        process_and_redirect(conn, variant)

      :error ->
        not_found(conn)
    end
  end

  defp verify_blob(repo, signed_blob_id) do
    with {:ok, blob_id} <- Verifier.verify_blob_id(signed_blob_id) do
      case repo.get(Blob, blob_id) do
        nil ->
          :error

        blob ->
          {:ok, blob}
      end
    end
  end

  defp verify_variant(repo, signed_blob_id, signed_transforms) do
    with {:ok, transforms} <- Verifier.verify_transforms(signed_transforms),
         {:ok, blob} <- verify_blob(repo, signed_blob_id) do
      {:ok, Variant.new(blob, transforms)}
    end
  end

  defp process_and_redirect(conn, variant) do
    case Variant.process(variant) do
      :ok ->
        redirect(conn, variant.key)

      {:error, reason} ->
        raise "Failed to transform key: #{variant.blob.key} (reason: #{inspect(reason)})"
    end
  end

  def redirect(conn, key) do
    case Storage.get_signed_url(key) do
      {:ok, url} ->
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, reason} ->
        raise "Failed to generate URL for key: #{key} (reason: #{inspect(reason)})"
    end
  end

  def not_found(conn) do
    send_resp(conn, 404, "")
  end
end
