defmodule Upload.Adapter do
  @moduledoc """
  A behaviour that specifies how an adapter should work.
  """

  defmacro __using__(_) do
    quote do
      @behaviour Upload.Adapter
    end
  end

  @callback get_url(String.t()) :: String.t()
  @callback get_signed_url(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback transfer(Upload.t()) :: {:ok, Upload.transferred()} | {:error, String.t()}
end
