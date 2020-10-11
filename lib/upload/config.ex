defmodule Upload.Config do
  def get(name \\ Upload, key, default \\ nil) do
    :upload
    |> Application.get_env(name, [])
    |> Keyword.get(key, default)
  end
end
