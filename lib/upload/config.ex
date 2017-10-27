defmodule Upload.Config do
  @doc """
  Get a configuration variable and fallback to the default.

  ## Examples

      iex> Upload.Config.get([foo: 1], :foo, 3)
      1

      iex> Upload.Config.get([], :foo, 3)
      3

  """
  @spec get(list, atom, any) :: any
  def get(config, key, default) do
    if Keyword.has_key?(config, key) do
      fetch!(config, key)
    else
      default
    end
  end

  @doc """
  Get a configuration variable, or raise an error.

  ## Examples

      iex> Upload.Config.fetch!([foo: 1], :foo)
      1

      iex> Upload.Config.fetch!([foo: {:system, "FOOBAR"}], :foo)
      nil

      iex> Upload.Config.fetch!([], :foo)
      ** (KeyError) key :foo not found in: []

  """
  @spec fetch!(list, atom) :: any | no_return
  def fetch!(config, key) do
    with {:system, varname} <- Keyword.fetch!(config, key) do
      System.get_env(varname)
    end
  end
end
