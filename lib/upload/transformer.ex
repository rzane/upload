defmodule Upload.Transformer do
  @moduledoc """
  Applies transformations to an image.

  See: https://imagemagick.org/script/command-line-options.php
  """

  alias Upload.Utils

  def transform(source, destination, transforms) do
    args = Enum.reduce(transforms, [], &reduce/2)
    args = args ++ ["-write", destination, source]

    case Utils.cmd(:mogrify, args) do
      {:ok, _} ->
        :ok

      {:error, :enoent} ->
        raise "Transformations cannot be applied because mogrify is not installed."

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reduce({name, param}, args) when is_atom(name) do
    args ++ ["-" <> to_flag(name), param]
  end

  # FIXME: Whitelist command-line options
  defp to_flag(name) do
    name |> to_string() |> String.replace("_", "-")
  end
end
