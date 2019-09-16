defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  alias Upload.Config
  alias Upload.Blob

  @spec get_public_url(Blob.t(), Keyword.t()) :: binary()
  def get_public_url(%Blob{key: key}, opts \\ []) do
    Config.file_store()
    |> FileStore.get_public_url(key, opts)
  end

  @spec get_signed_url(Blob.t(), Keyword.t()) :: {:ok, binary()} | :error
  def get_signed_url(%Blob{key: key}, opts \\ []) do
    Config.file_store()
    |> FileStore.get_signed_url(key, opts)
  end
end
