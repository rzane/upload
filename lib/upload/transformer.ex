defmodule Upload.Transformer do
  # TODO: Check for Mogrify

  def transform(path, transformations) do
    image =
      transformations
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
