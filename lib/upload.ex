defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  alias Ecto.UUID

  defstruct [:key, :path, :content_type, :filename, :byte_size, :checksum]

  @type t() :: %__MODULE__{
          key: binary(),
          path: Path.t(),
          filename: binary(),
          content_type: binary() | nil,
          byte_size: non_neg_integer() | nil,
          checksum: binary() | nil
        }

  @type keyable() :: t() | Upload.Blob.t() | binary()

  @spec get_public_url(keyable(), Keyword.t()) :: binary()
  def get_public_url(upload, opts \\ []) do
    FileStore.get_public_url(file_store(), get_key(upload), opts)
  end

  @spec get_signed_url(keyable(), Keyword.t()) :: {:ok, binary()} | :error
  def get_signed_url(upload, opts \\ []) do
    FileStore.get_signed_url(file_store(), get_key(upload), opts)
  end

  @spec file_store() :: FileStore.t()
  def file_store() do
    case Application.get_env(:upload, :file_store, []) do
      {module, function_name} ->
        apply(module, function_name, [])

      config ->
        FileStore.new(config)
    end
  end

  @spec from_path(Plug.Upload.t()) :: t()
  def from_plug(%Plug.Upload{} = upload) do
    %Upload{
      key: UUID.generate(),
      path: upload.path,
      filename: upload.filename,
      content_type: upload.content_type
    }
  end

  @spec from_path(Path.t()) :: t()
  def from_path(path) do
    %Upload{
      key: UUID.generate(),
      path: path,
      filename: Path.basename(path),
      content_type: MIME.from_path(path)
    }
  end

  defp get_key(%Upload{key: key}), do: key
  defp get_key(%Upload.Blob{key: key}), do: key
  defp get_key(key) when is_binary(key), do: key
end
