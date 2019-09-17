defmodule ExampleWeb.UserView do
  use ExampleWeb, :view

  def blob_path(blob) do
    Upload.Endpoint.blob_path(blob)
  end

  defp variant_path(blob, transforms) do
    Upload.Endpoint.variant_path(blob, transforms)
  end
end
