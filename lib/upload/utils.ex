defmodule Upload.Utils do
  @moduledoc false

  require Logger

  def secret_key_base, do: fetch_config!(:secret_key_base)
  def table_name, do: get_config(:table_name, "blobs")

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

  defp get_config(key, default) do
    Application.get_env(:upload, key, default)
  end

  defp fetch_config!(key) do
    Application.fetch_env!(:upload, key)
  end
end
