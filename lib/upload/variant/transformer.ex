defmodule Upload.Variant.Transformer do
  @moduledoc """
  Applies transformations to an image.

  See: https://imagemagick.org/script/command-line-options.php
  """

  def transform(source, destination, transforms) do
    args = Enum.reduce(transforms, [], &reduce/2)
    args = args ++ ["-write", destination, source]

    with {:ok, _} <- mogrify(args) do
      :ok
    end
  end

  defp reduce({name, param}, args) when is_atom(name) do
    args ++ ["-" <> to_flag(name), param]
  end

  # FIXME: Whitelist command-line options
  defp to_flag(name) do
    name |> to_string() |> String.replace("_", "-")
  end

  defp mogrify(args) do
    :upload
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:mogrify, "mogrify")
    |> Upload.Utils.cmd(args)
  end
end
