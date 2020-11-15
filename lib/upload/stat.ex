defmodule Upload.Stat do
  alias Upload.Stat.Image
  alias Upload.Stat.Video

  defstruct [:path, :filename, :byte_size, :checksum, :metadata, :content_type]

  @chunk_size 2_048
  @octet_stream "application/octet-stream"

  @type error :: File.posix() | Exception.t()

  @type t :: %__MODULE__{
          path: Path.t(),
          filename: binary(),
          checksum: binary(),
          byte_size: non_neg_integer(),
          metadata: map() | nil,
          content_type: binary() | nil
        }

  @callback stat(Path.t(), FileType.mime()) ::
              {:ok, map() | nil} | {:error, Exception.t()}

  @doc false
  @spec stat(Path.t()) :: {:ok, t()} | {:error, error()}
  def stat(path) do
    with {:ok, byte_size} <- get_byte_size(path),
         {:ok, checksum} <- compute_checksum(path),
         {:ok, detected_type} <- detect_type(path),
         {:ok, metadata} <- analyze(path, detected_type) do
      content_type = get_content_type(path, detected_type)

      stat = %__MODULE__{
        path: path,
        byte_size: byte_size,
        checksum: checksum,
        metadata: metadata,
        content_type: content_type,
        filename: Path.basename(path)
      }

      {:ok, stat}
    end
  end

  @doc false
  def put(stat, _key, nil) do
    stat
  end

  def put(stat, :content_type, preferred_type) do
    Map.update!(stat, :content_type, fn
      @octet_stream -> preferred_type
      detected_type -> detected_type
    end)
  end

  def put(stat, key, value) do
    Map.put(stat, key, value)
  end

  defp get_byte_size(path) do
    case File.stat(path, time: :posix) do
      {:ok, %File.Stat{size: size, type: :regular}} -> {:ok, size}
      {:ok, _} -> {:error, :eisdir}
      {:error, reason} -> {:error, reason}
    end
  end

  defp detect_type(path) do
    case FileType.from_path(path) do
      {:ok, {_, detected_type}} -> {:ok, detected_type}
      {:error, :unrecognized} -> {:ok, nil}
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_content_type(path, nil) do
    MIME.from_path(path)
  end

  defp get_content_type(_path, detected_type) do
    detected_type
  end

  defp compute_checksum(path) do
    File.open(path, [:read, :binary], fn io ->
      io
      |> IO.binstream(@chunk_size)
      |> FileStore.Stat.checksum()
    end)
  end

  defp analyze(path, nil) do
    analyze(path, @octet_stream)
  end

  defp analyze(path, content_type) do
    analyzers =
      case Application.fetch_env(:upload, :analyze) do
        {:ok, true} -> [Image, Video]
        {:ok, false} -> []
        {:ok, providers} -> providers
        :error -> []
      end

    Enum.find_value(analyzers, {:ok, nil}, fn analyzer ->
      case analyzer.stat(path, content_type) do
        {:ok, nil} -> nil
        {:ok, metadata} -> {:ok, metadata}
        {:error, reason} when is_struct(reason) -> {:error, reason}
      end
    end)
  end
end
