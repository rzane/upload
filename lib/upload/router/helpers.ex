defmodule Upload.Router.Helpers do
  alias Upload.Blob
  alias Upload.Verifier

  defmacro __using__(config) do
    quote location: :keep do
      def blob_path(conn, blob, opts \\ []) do
        opts = Keyword.merge(unquote(config), opts)
        unquote(__MODULE__).blob_path(conn, blob, opts)
      end

      def variant_path(conn, blob, transforms, opts \\ []) do
        opts = Keyword.merge(unquote(config), opts)
        unquote(__MODULE__).variant_path(conn, blob, transforms, opts)
      end
    end
  end

  def blob_path(conn, %Blob{} = blob, opts \\ []) do
    {proxy_path, opts} = Keyword.pop(opts, :proxy_path, "/storage")

    proxy_path
    |> clean_path()
    |> append_path("blobs")
    |> append_path(Verifier.sign_blob_id(conn, blob.id))
    |> append_path(blob.filename)
    |> append_query(opts)
  end

  def variant_path(conn, %Blob{} = blob, transforms, opts \\ []) do
    {proxy_path, opts} = Keyword.pop(opts, :proxy_path, "/storage")

    proxy_path
    |> clean_path()
    |> append_path("variants")
    |> append_path(Verifier.sign_blob_id(conn, blob.id))
    |> append_path(Verifier.sign_transforms(conn, transforms))
    |> append_path(blob.filename)
    |> append_query(opts)
  end

  defp clean_path(path), do: String.trim_trailing(path, "/")
  defp append_path(path, other_path), do: path <> "/" <> other_path
  defp append_query(path, []), do: path
  defp append_query(path, query), do: path <> "?" <> URI.encode_query(query)
end
