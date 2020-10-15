defmodule Upload.Transformer do
  alias Upload.Utils

  def transform(source, destination, transforms) do
    args = Enum.reduce(transforms, [], &reduce/2)
    args = args ++ ["-write", destination, source]

    case Utils.cmd(__MODULE__, :mogrify, args) do
      {:ok, _} ->
        :ok

      {:error, :enoent} ->
        raise "Transformations cannot be applied because mogrify is not installed."

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reduce({flag, param}, args) do
    add(args, normalize_flag(flag), param)
  end

  defp normalize_flag(flag) do
    flag
    |> to_string()
    |> String.replace("_", "-")
  end

  defp add(args, "resize-to-limit", param) do
    add(args, "resize", "#{param}>")
  end

  defp add(args, flag, param) when is_binary(param) do
    args ++ ["-#{flag}", param]
  end
end
