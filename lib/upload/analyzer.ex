defmodule Upload.Analyzer do
  @callback get_metadata(Path.t()) :: {:ok, map()} | {:error, term()}
end
