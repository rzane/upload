defmodule Upload.Analyzer.Image do
  @moduledoc false

  @spec analyze(Path.t()) :: {:ok, map()} | :error
  def analyze(path) do
    image = path |> Mogrify.open() |> Mogrify.verbose()
    {:ok, %{height: image.height, width: image.width}}
  rescue
    _error ->
      :error
  end
end
