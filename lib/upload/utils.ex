defmodule Upload.Utils do
  require Logger

  def log(level, message) do
    if get_config(:log, true) do
      Logger.log(level, message)
    end
  end

  def fetch_config!(name \\ Upload, key) do
    :upload
    |> Application.fetch_env!(name)
    |> Keyword.fetch!(key)
  end

  def get_config(name \\ Upload, key, default \\ nil) do
    :upload
    |> Application.get_env(name, [])
    |> Keyword.get(key, default)
  end

  def cmd(name, cmd, args) do
    config = get_config(name, cmd, [])
    cmd = Keyword.get(config, :cmd, to_string(cmd))
    args = Keyword.get(config, :args, []) ++ args

    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {out, 0} -> {:ok, out}
      {_, status} -> {:error, {:exit, status}}
    end
  rescue
    e in [ErlangError] -> {:error, e.original}
  end
end
