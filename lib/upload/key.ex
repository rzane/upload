defmodule Upload.Key do
  @type t() :: binary()

  @base36_alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: t()
  def generate, do: random_base36(28)

  # Pretty much a blatant ripoff of ActiveSupport's SecureRandom#base36
  defp random_base36(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> :binary.bin_to_list()
    |> Enum.map_join(fn byte -> byte |> rem(64) |> base36() end)
  end

  for {digit, index} <- Enum.with_index(@base36_alphabet) do
    defp base36(unquote(index)), do: <<unquote(digit)>>
  end

  defp base36(_), do: base36(:random.uniform(36) - 1)
end
