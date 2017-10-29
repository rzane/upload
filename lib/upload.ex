defmodule Upload do
  @moduledoc """
  An opinionated file uploader.
  """

  @enforce_keys [:key, :path, :filename]
  defstruct [:key, :path, :filename, status: :pending]

  @type t :: %Upload{
    key: String.t,
    filename: String.t,
    path: String.t
  }

  @type transferred :: %Upload{
    key: String.t,
    filename: String.t,
    path: String.t,
    status: :transferred
  }

  @type uploadable :: Plug.Upload.t | Upload.t
  @type uploadable_path :: String.t | Upload.t

  @doc """
  Get the adapter from config.
  """
  def adapter do
    Upload.Config.get(__MODULE__, :adapter, Upload.Adapters.Local)
  end

  @doc """
  Get the URL for a given key. It will behave differently based
  on the adapter you're using.

  ### Local

      iex> Upload.get_url("123456.png")
      "/uploads/123456.png"

  ### S3

      iex> Upload.get_url("123456.png")
      "https://my_bucket_name.s3.amazonaws.com/123456.png"

  ### Fake / Test

      iex> Upload.get_url("123456.png")
      "123456.png"

  """
  @spec get_url(Upload.t | String.t) :: String.t
  def get_url(%__MODULE__{key: key}), do: get_url(key)
  def get_url(key) when is_binary(key), do: adapter().get_url(key)

  @doc """
  Transfer the file to where it will be stored.
  """
  @spec transfer(Upload.t) :: {:ok, Upload.transferred} | {:error, String.t}
  def transfer(%__MODULE__{} = upload), do: adapter().transfer(upload)

  @doc """
  Converts a `Plug.Upload` to an `Upload`.

  ## Examples

      iex> Upload.cast(%Plug.Upload{path: "/path/to/foo.png", filename: "foo.png"})
      {:ok, %Upload{path: "/path/to/foo.png", filename: "foo.png", key: "123456.png"}}

      iex> Upload.cast(100)
      :error

  """
  @spec cast(uploadable, list) :: {:ok, Upload.t} | :error
  def cast(uploadable, opts \\ [])
  def cast(%Upload{} = upload, _opts), do: {:ok, upload}
  def cast(%Plug.Upload{filename: filename, path: path}, opts) do
    do_cast(filename, path, opts)
  end
  def cast(_not_uploadable, _opts) do
    :error
  end

  @doc """
  Cast a file path to an `Upload`.

  *Warning:* Do not use `cast_path` with unsanitized user input.

  ## Examples

      iex> Upload.cast_path("/path/to/foo.png")
      {:ok, %Upload{path: "/path/to/foo.png", filename: "foo.png", key: "123456.png"}}

      iex> Upload.cast_path(100)
      :error

  """
  @spec cast_path(uploadable_path, list) :: {:ok, Upload.t} | :error
  def cast_path(path, opts \\ [])
  def cast_path(%Upload{} = upload, _opts), do: {:ok, upload}
  def cast_path(path, opts) when is_binary(path) do
    path
    |> Path.basename
    |> do_cast(path, opts)
  end
  def cast_path(_, _opts) do
    :error
  end

  defp do_cast(filename, path, opts) do
    {:ok, %__MODULE__{
      key: generate_key(filename, opts),
      path: path,
      filename: filename,
      status: :pending
    }}
  end

  @doc """
  Converts a filename to a unique key.

  ## Examples

      iex> Upload.generate_key("phoenix.png")
      "b9452178-9a54-5e99-8e64-a059b01b88cf.png"

      iex> Upload.generate_key("phoenix.png", prefix: ["logos"])
      "logos/b9452178-9a54-5e99-8e64-a059b01b88cf.png"

  """
  @spec generate_key(String.t, [{:prefix, list}]) :: String.t
  def generate_key(filename, opts \\ []) when is_binary(filename) do
    uuid = UUID.uuid4(:hex)
    ext  = get_extension(filename)

    opts
    |> Keyword.get(:prefix, [])
    |> Path.join(uuid <> ext)
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

      iex> {:ok, upload} = Upload.cast_path("/path/to/foo.png")
      ...> Upload.get_extension(upload)
      ".png"

  """
  @spec get_extension(String.t | Upload.t) :: String.t
  def get_extension(%Upload{filename: filename}) do
    get_extension(filename)
  end
  def get_extension(filename) when is_binary(filename) do
    filename |> Path.extname |> String.downcase
  end
end
