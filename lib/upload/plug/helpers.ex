defmodule Upload.Plug.Helpers do
  alias Upload.Key
  alias Upload.Blob

  @spec blob_path(Plug.Conn.t(), Blob.t() | Key.t(), Keyword.t() | map()) :: binary()
  def blob_path(_conn, blob_or_key, query \\ []) do
    "/storage/blobs/"
    |> append(sign_blob(blob_or_key))
    |> append_query(query)
  end

  @spec variant_path(Plug.Conn.t(), Blob.t() | Key.t(), Keyword.t(), Keyword.t()) :: binary()
  def variant_path(_conn, blob_or_key, transforms, query \\ []) do
    "/storage/variants/"
    |> append(sign_blob(blob_or_key))
    |> append("/")
    |> append(sign_transforms(transforms))
    |> append_query(query)
  end

  defp sign_blob(blob_or_key) do
    blob_or_key |> get_key() |> Key.sign(:blob)
  end

  defp sign_transforms(transforms) do
    transforms
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
    |> Key.sign(:transform)
  end

  defp get_key(%Blob{key: key}), do: key
  defp get_key(key) when is_binary(key), do: key

  defp append(left, right), do: left <> right

  defp append_query(url, []), do: url
  defp append_query(url, %{}), do: url
  defp append_query(url, query), do: "#{url}?#{URI.encode_query(query)}"
end
