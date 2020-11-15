defmodule Upload.Stat do
  defstruct [:path, :filename, :byte_size, :checksum, :metadata, :content_type]

  @chunk_size 2_048
  @octet_stream "application/octet-stream"

  @type filename :: binary()
  @type checksum :: binary()
  @type byte_size :: non_neg_integer()
  @type content_type :: FileType.mime()
  @type metadata :: map() | nil
  @type error :: File.posix() | Exception.t()

  @type t :: %__MODULE__{
          path: Path.t(),
          filename: filename(),
          byte_size: byte_size(),
          checksum: checksum(),
          metadata: metadata(),
          content_type: content_type()
        }

  @callback stat(Path.t(), content_type()) ::
              {:ok, metadata()} | {:error, Exception.t()}

  @spec stat(Path.t()) :: {:ok, t()} | {:error, error()}
  def stat(path) do
    with {:ok, byte_size} <- get_byte_size(path),
         {:ok, {checksum, content_type}} <- open(path, &read/1),
         {:ok, metadata} <- get_metadata(path, content_type) do
      stat = %__MODULE__{
        path: path,
        filename: Path.basename(path),
        byte_size: byte_size,
        checksum: checksum,
        content_type: content_type,
        metadata: metadata
      }

      {:ok, stat}
    end
  end

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

  defp open(path, fun) do
    case File.open(path, [:read, :binary], fun) do
      {:ok, result} -> result
      {:error, reason} -> {:error, reason}
    end
  end

  defp read(io) do
    checksum = compute_checksum(io)

    with {:ok, content_type} <- detect_type(io) do
      {:ok, {checksum, content_type}}
    end
  end

  defp detect_type(io) do
    case FileType.from_io(io) do
      {:ok, {_, detected_type}} -> {:ok, detected_type}
      {:error, :unrecognized} -> {:ok, @octet_stream}
      {:error, reason} -> {:error, reason}
    end
  end

  defp compute_checksum(io) do
    io
    |> IO.binstream(@chunk_size)
    |> FileStore.Stat.checksum()
  end

  defp get_metadata(path, content_type) do
    Upload
    |> Application.get_env(:metadata, [])
    |> Enum.find_value({:ok, nil}, fn provider ->
      case provider.stat(path, content_type) do
        {:ok, nil} ->
          nil

        {:ok, metadata} ->
          {:ok, metadata}

        {:error, reason} when is_struct(reason) ->
          {:error, reason}
      end
    end)
  end
end
