defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  alias Upload.Config
  alias Upload.Blob

  @spec get_public_url(Key.t() | Blob.t(), Keyword.t()) :: binary()
  def get_public_url(blob_or_key, opts \\ [])
  def get_public_url(%Blob{key: key}, opts), do: get_public_url(key, opts)
  def get_public_url(key, opts) when is_binary(key) do
    FileStore.get_public_url(Config.file_store(), key, opts)
  end

  @spec get_signed_url(Key.t() | Blob.t(), Keyword.t()) :: {:ok, binary()} | {:error, term()}
  def get_signed_url(blob_or_key, opts \\ [])
  def get_signed_url(%Blob{key: key}, opts), do: get_signed_url(key, opts)
  def get_signed_url(key, opts) when is_binary(key) do
    FileStore.get_signed_url(Config.file_store(), key, opts)
  end
end
