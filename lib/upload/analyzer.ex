defmodule Upload.Analyzer do
  @callback analyze(Path.t()) :: {:ok, map()} | {:error, term()}
end
