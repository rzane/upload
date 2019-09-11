defmodule Upload.Config do
  @moduledoc false

  @doc """
  Get a configuration variable and fallback to the default.
  """
  @spec get(atom, atom, any) :: any
  def get(mod, key, default) do
    :upload
    |> Application.get_env(mod, [])
    |> Keyword.get(key, default)
    |> normalize_config()
  end

  @doc """
  Get a configuration variable, or raise an error.
  """
  @spec fetch!(atom, atom) :: any | no_return
  def fetch!(mod, key) do
    :upload
    |> Application.get_env(mod, [])
    |> Keyword.fetch!(key)
    |> normalize_config()
  end

  defp normalize_config({:system, varname}), do: System.get_env(varname)
  defp normalize_config(value), do: value
end
