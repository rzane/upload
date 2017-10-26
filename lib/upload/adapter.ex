defmodule Upload.Adapter do
  defmacro __using__(_) do
    quote do
      import Upload.Adapter
      @behaviour Upload.Adapter
    end
  end

  @callback get_url(String.t) :: String.t
  @callback transfer(Upload.t) :: {:ok, Upload.t} | {:error, String.t}

  @doc """
  Join URL segments.

  ## Examples

      iex> Upload.Adapter.join_url("/foo", "bar.png")
      "/foo/bar.png"

      iex> Upload.Adapter.join_url("/foo/", "/bar.png")
      "/foo/bar.png"

  """
  def join_url(a, b) do
    String.trim_trailing(a, "/") <> "/" <> String.trim_leading(b, "/")
  end

  def get_config(config, key, default) do
    if Keyword.has_key?(config, key) do
      fetch_config!(config, key)
    else
      default
    end
  end

  def fetch_config!(config, key) do
    with {:system, varname} <- Keyword.fetch!(config, key) do
      System.get_env(varname)
    end
  end
end
