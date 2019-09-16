defmodule Upload.Analyzer do
  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  @callback get_metadata(Path.t(), binary() | nil) ::
              {:ok, map()} | {:info, binary()} | {:error, binary()}
end
