if Code.ensure_compiled?(Mogrify) do
  defmodule Upload.Transformer do
    @spec transform(Path.t(), Path.t(), map()) :: :ok | {:error, term()}
    def transform(source, destination, transforms) do
      transforms
      |> Enum.reduce(Mogrify.open(source), &do_transform/2)
      |> Mogrify.save(path: destination)

      :ok
    rescue
      error -> {:error, error}
    end

    defp do_transform({"resize", param}, image) do
      Mogrify.resize(image, param)
    end

    defp do_transform({"resize_to_fill", param}, image) do
      Mogrify.resize_to_fill(image, param)
    end

    defp do_transform({"resize_to_limit", param}, image) do
      Mogrify.resize_to_fill(image, param)
    end

    defp do_transform(_transformation, image), do: image
  end
else
  defmodule Upload.Transformer do
    @spec transform(Path.t(), Path.t(), map()) :: :ok | {:error, term()}
    def transform(_source, _destination, _transforms) do
      raise "Mogrify is not installed"
    end
  end
end
