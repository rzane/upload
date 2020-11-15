defmodule Upload.Utils do
  @moduledoc false

  require Logger

  alias Upload.ExitError
  alias Upload.CommandError

  def repo do
    Application.fetch_env!(:upload, :repo)
  end

  def secret_key_base do
    case Application.fetch_env!(:upload, :secret_key_base) do
      {mod, fun} -> apply(mod, fun, [])
      {mod, fun, args} -> apply(mod, fun, args)
      key_base when is_binary(key_base) -> key_base
    end
  end

  def json_library do
    Application.get_env(:upload, :json_library, Jason)
  end

  def cmd(cmd, args) do
    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {out, 0} ->
        {:ok, out}

      {_, status} ->
        {:error, %ExitError{cmd: cmd, status: status}}
    end
  rescue
    e in [ErlangError] ->
      {:error, %CommandError{cmd: cmd, reason: e.original}}
  end

  def log(message, level) do
    if Application.get_env(:upload, :log, true) do
      Logger.log(level, message)
    end
  end
end
