defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  @enforce_keys [:key, :path, :filename]
  defstruct [:key, :path, :filename, status: :pending]

  @config Application.get_env(:upload, __MODULE__, [adapter: Upload.Adapters.Local])
  @adapter Keyword.get(@config, :adapter)

  defdelegate get_url(key), to: @adapter
  defdelegate transfer(upload), to: @adapter

  @doc """
  Normalizes an uploadable dataum into something we can transfer.

  ## Examples

      iex> Upload.cast(%Plug.Upload{path: "/path/to/foo.png", filename: "bar.png"})
      {:ok, %Upload{
        status: :pending,
        filename: "bar.png",
        path: "/path/to/foo.png",
        key: "7b083d33-b725-547e-908c-1b6d21462569.png",
      }}

      iex> Upload.cast(%Plug.Upload{path: "/path/to/foo.png", filename: "bar.png"}, prefix: ["logos"])
      {:ok, %Upload{
        status: :pending,
        filename: "bar.png",
        path: "/path/to/foo.png",
        key: "logos/7b083d33-b725-547e-908c-1b6d21462569.png",
      }}
  """
  def cast(uploadable, opts \\ [])
  def cast(%Upload{} = upload, _opts), do: upload
  def cast(%Plug.Upload{filename: filename, path: path}, opts) do
    do_cast(filename, path, opts)
  end

  @doc """
  Cast a file path to an `%Upload{}`.

  *Warning:* Do not cast_path with unsanitized user input.

  ## Examples

      iex> Upload.cast_path("/path/to/foo.png")
      {:ok, %Upload{
        status: :pending,
        filename: "foo.png",
        path: "/path/to/foo.png",
        key: "91ce276a-1c76-500b-add7-e4e13bba4c07.png"
      }}

      iex> Upload.cast_path("/path/to/foo.png", prefix: ["logos"])
      {:ok, %Upload{
        status: :pending,
        filename: "foo.png",
        path: "/path/to/foo.png",
        key: "logos/91ce276a-1c76-500b-add7-e4e13bba4c07.png"
      }}

  """
  def cast_path(path, opts \\ []) when is_binary(path) do
    path
    |> Path.basename
    |> do_cast(path, opts)
  end

  defp do_cast(filename, path, opts) do
    {:ok, %__MODULE__{
      key: get_key(filename, opts),
      path: path,
      filename: filename,
      status: :pending
    }}
  end

  @doc """
  Converts a filename to a unique key.

  ## Examples

      iex> Upload.get_key("phoenix.png")
      "b9452178-9a54-5e99-8e64-a059b01b88cf.png"

      iex> Upload.get_key("phoenix.png", prefix: ["logos"])
      "logos/b9452178-9a54-5e99-8e64-a059b01b88cf.png"

  """
  def get_key(filename, opts \\ []) when is_binary(filename) do
    uuid = UUID.uuid4(:hex)
    ext  = get_extension(filename)

    opts
    |> Keyword.get(:prefix, [])
    |> Path.join("#{uuid}#{ext}")
  end

  @doc """
  Gets the extension from a filename.

  ## Examples

      iex> Upload.get_extension("foo.png")
      ".png"

      iex> Upload.get_extension("foo.PNG")
      ".png"

      iex> Upload.get_extension("foo")
      ""

  """
  def get_extension(filename) when is_binary(filename) do
    filename |> Path.extname |> String.downcase
  end
end
