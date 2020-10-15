defmodule Upload.Analyzer.Null do
  @moduledoc false

  @behaviour Upload.Analyzer

  @impl true
  def accept?(_), do: true

  @impl true
  def analyze(_), do: {:ok, %{}}
end
