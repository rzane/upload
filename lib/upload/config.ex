defmodule Upload.Config do
  @doc """
  Get a configuration variable and fallback to the default.
  """
  @spec get_config(list, atom, any) :: any
  def get_config(config, key, default) do
    if Keyword.has_key?(config, key) do
      fetch_config!(config, key)
    else
      default
    end
  end

  @doc """
  Get a configuration variable, or raise an error.
  """
  @spec fetch_config!(list, atom) :: any
  def fetch_config!(config, key) do
    with {:system, varname} <- Keyword.fetch!(config, key) do
      System.get_env(varname)
    end
  end
end
