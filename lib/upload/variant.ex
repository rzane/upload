defmodule Upload.Variant do
  alias Upload.Blob
  alias Upload.Token

  def generate_key(%Blob{key: key}, transforms) do
    transform_key = Token.sign(transforms, :variant)
    "variants/#{key}/#{hexdigest(transform_key)}"
  end

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end
end
