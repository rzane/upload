defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  @spec get_public_url(Upload.Blob.t(), Keyword.t()) :: binary()
  def get_public_url(%Upload.Blob{key: key}, opts \\ []) do
    FileStore.get_public_url(get_file_store(), key, opts)
  end

  @spec get_signed_url(Upload.Blob.t(), Keyword.t()) :: {:ok, binary()} | :error
  def get_signed_url(%Upload.Blob{key: key}, opts \\ []) do
    FileStore.get_signed_url(get_file_store(), key, opts)
  end

  @spec get_file_store() :: FileStore.t()
  def get_file_store() do
    case Application.get_env(:upload, :file_store, []) do
      {module, function_name} ->
        apply(module, function_name, [])

      config ->
        FileStore.new(config)
    end
  end
end
