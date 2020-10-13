defmodule Upload.Utils do
  require Logger

  def log(level, message) do
    if Application.get_env(:upload, :log, true) do
      Logger.log(level, message)
    end
  end

  def get_config(name \\ Upload, key, default \\ nil) do
    :upload
    |> Application.get_env(name, [])
    |> Keyword.get(key, default)
  end
end
