defmodule Upload.Adapter do
  defmacro __using__(_) do
    quote do
      @behaviour Upload.Adapter

      import Upload.Adapter
      import Upload.Config
    end
  end

  @callback get_url(String.t) :: String.t
  @callback transfer(Upload.t) :: {:ok, Upload.transferred} | {:error, any}
end
