defmodule ExampleWeb.UserView do
  use ExampleWeb, :view

  def blob_path(blob) do
    "/upload/blobs/#{blob.key}"
  end

  defp variant_path(blob, transforms) do
    variation_key =
      transforms
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Upload.Key.sign(:variation)

    "/upload/variant/#{blob.key}/#{variation_key}"
  end
end
