defmodule Upload.Analyzer.Video do
  @behaviour Upload.Analyzer

  def get_metadata(_path) do
    {:ok, %{}}
  end
end
