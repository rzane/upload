defmodule Upload.Analyzer do
  @callback accept?(binary()) :: boolean()
  @callback analyze(Path.t()) :: {:ok, map()} | {:error, term()}
end
