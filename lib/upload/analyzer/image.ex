if Code.ensure_compiled?(Mogrify) do
  defmodule Upload.Analyzer.Image do
    @moduledoc false

    require Logger

    @spec get_metadata(Path.t()) :: map()
    def get_metadata(path) do
      image = path |> Mogrify.open() |> Mogrify.verbose()

      %{height: image.height, width: image.width}
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.into(%{})
    rescue
      error ->
        Logger.error("Skipping image analysis due to a Mogrify error: #{inspect(error)}")
        %{}
    end
  end
else
  defmodule Upload.Analyzer.Image do
    require Logger

    @spec get_metadata(Path.t()) :: map()
    def get_metadata(_) do
      Logger.info("Skipping image analysis because the mogrify package is not installed")
      %{}
    end
  end
end
