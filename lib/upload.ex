defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  alias Ecto.UUID

  defstruct [:key, :path, :content_type, :filename]

  @type t() :: %__MODULE__{
          key: binary(),
          path: Path.t(),
          filename: binary(),
          content_type: binary() | nil
        }

  @spec file_store() :: FileStore.t()
  def file_store() do
    :upload
    |> Application.get_env(:file_store, [])
    |> FileStore.new()
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
end
