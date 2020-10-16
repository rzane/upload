defmodule Upload.Verifier do
  alias Upload.Utils
  alias Upload.Blob
  alias Upload.Variant
  alias Plug.Crypto.MessageVerifier

  @spec sign_blob_id(Blob.id()) :: binary()
  def sign_blob_id(id) do
    sign(id, "blob")
  end

  @spec verify_blob_id(binary()) :: {:ok, Blob.id()} | :error
  def verify_blob_id(signed_id) do
    verify(signed_id, "blob")
  end

  @spec sign_transforms(Variant.transforms()) :: binary()
  def sign_transforms(transforms) do
    sign(transforms, "transforms")
  end

  @spec verify_transforms(binary()) :: {:ok, Variant.transforms()} | :error
  def verify_transforms(signed_transforms) do
    verify(signed_transforms, "transforms")
  end

  defp sign(data, salt) do
    secret = Utils.generate_secret(salt)

    data
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(secret)
  end

  defp verify(token, salt) do
    secret = Utils.generate_secret(salt)

    with {:ok, message} <- MessageVerifier.verify(token, secret) do
      {:ok, Plug.Crypto.non_executable_binary_to_term(message)}
    end
  end
end
