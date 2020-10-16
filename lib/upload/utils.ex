defmodule Upload.Utils do
  @moduledoc false

  require Logger

  alias Upload.Analyzer.Null
  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier

  def table_name do
    get_config(:table_name, "blobs")
  end

  def sign(data, salt) do
    secret = get_secret(salt)

    data
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(secret)
  end

  def verify(token, salt) do
    secret = get_secret(salt)

    with {:ok, message} <- MessageVerifier.verify(token, secret) do
      {:ok, Plug.Crypto.non_executable_binary_to_term(message)}
    end
  end

  def analyze(path, content_type) do
    analyzers = get_config(:analyzers, [])
    analyzer = Enum.find(analyzers, Null, & &1.accept?(content_type))
    analyzer.analyze(path)
  end

  def json_decode(data) do
    decoder = get_config(:json_library, Jason)
    decoder.decode(data)
  end

  def cmd(cmd, args) do
    config = get_config(cmd, [])
    cmd = Keyword.get(config, :cmd, to_string(cmd))
    args = Keyword.get(config, :args, []) ++ args

    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {out, 0} -> {:ok, out}
      {_, status} -> {:error, {:exit, status}}
    end
  rescue
    e in [ErlangError] -> {:error, e.original}
  end

  for level <- [:debug, :warn, :info, :error] do
    def unquote(level)(message) do
      if get_config(:log, true) do
        Logger.log(unquote(level), message)
      end
    end
  end

  defp get_secret(salt) do
    :secret_key_base
    |> fetch_config!()
    |> KeyGenerator.generate(to_string(salt))
  end

  defp get_config(key, default) do
    Application.get_env(:upload, key, default)
  end

  defp fetch_config!(key) do
    Application.fetch_env!(:upload, key)
  end
end
