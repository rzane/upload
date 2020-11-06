defmodule Upload.Utils do
  @moduledoc false

  require Logger

  def table_name do
    get_config(:table_name, "blobs")
  end

  def repo do
    fetch_config!(:repo)
  end

  def secret_key_base do
    case fetch_config!(:secret_key_base) do
      {mod, fun} -> apply(mod, fun, [])
      {mod, fun, args} -> apply(mod, fun, args)
      key_base when is_binary(key_base) -> key_base
    end
  end

  def analyze(_path, nil), do: {:ok, %{}}

  def analyze(path, content_type) do
    :analyzers
    |> get_config([])
    |> Enum.find_value({:ok, %{}}, fn analyzer ->
      if analyzer.accept?(content_type) do
        analyzer.analyze(path)
      end
    end)
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

  def log(message, level) do
    if get_config(:log, true) do
      Logger.log(level, message)
    end
  end

  defp get_config(key, default) do
    Application.get_env(:upload, key, default)
  end

  defp fetch_config!(key) do
    Application.fetch_env!(:upload, key)
  end
end
