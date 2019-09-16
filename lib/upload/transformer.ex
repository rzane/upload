defmodule Upload.Transformer do
  # TODO: Check for Mogrify
  # TODO: If the list of transforms is empty, the transformer should short circuit.
  # TODO: Handle errors

  def transform(path, transforms) do
    image =
      transforms
      |> Enum.reduce(Mogrify.open(path), &do_transform/2)
      |> Mogrify.save()

    {:ok, image.path}
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
