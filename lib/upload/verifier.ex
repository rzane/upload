defmodule Upload.Verifier do
  alias Upload.Blob
  alias Upload.Variant
  alias Plug.Conn
  alias Plug.Crypto

  @type key_base :: Conn.t() | atom() | binary()

  @spec sign_blob_id(key_base(), Blob.id()) :: binary()
  def sign_blob_id(conn, id) do
    sign(conn, id, "blob")
  end

  @spec verify_blob_id(key_base(), binary()) :: {:ok, Blob.id()} | :error
  def verify_blob_id(conn, signed_id) do
    verify(conn, signed_id, "blob")
  end

  @spec sign_transforms(key_base(), Variant.transforms()) :: binary()
  def sign_transforms(conn, transforms) do
    sign(conn, transforms, "transforms")
  end

  @spec verify_transforms(key_base(), binary()) :: {:ok, Variant.transforms()} | :error
  def verify_transforms(conn, signed_transforms) do
    verify(conn, signed_transforms, "transforms")
  end

  defp sign(conn, data, salt) do
    conn
    |> get_key_base()
    |> Crypto.sign(salt, data)
  end

  defp verify(conn, token, salt) do
    conn
    |> get_key_base()
    |> Crypto.verify(salt, token)
  end

  defp get_key_base(%Conn{secret_key_base: secret_key_base}) do
    secret_key_base
  end

  defp get_key_base(endpoint) when is_atom(endpoint),
    do: endpoint.config(:secret_key_base)

  defp get_key_base(string) when is_binary(string) and byte_size(string) >= 20,
    do: string
end
