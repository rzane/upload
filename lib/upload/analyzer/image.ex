if Code.ensure_compiled?(Mogrify) do
  defmodule Upload.Analyzer.Image do
    use Upload.Analyzer

    @impl true
    def get_metadata(path, _) do
      with {:ok, image} <- open_image(path) do
        metadata =
          %{height: image.height, width: image.width}
          |> Enum.reject(fn {_, v} -> is_nil(v) end)
          |> Enum.into(%{})

        {:ok, metadata}
      end
    end

    defp open_image(path) do
      {:ok, path |> Mogrify.open() |> Mogrify.verbose()}
    rescue
      e -> {:error, "Skipping image analysis due to a Mogrify error: #{inspect(e)}"}
    end
  end
else
  defmodule Upload.Analyzer.Image do
    use Upload.Analyzer

    @impl true
    def get_metadata(_, _) do
      {:info, "Skipping image analysis because mogrify is not installed"}
    end
  end
end
