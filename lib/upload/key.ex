defmodule Upload.Key do
  @moduledoc false

  @base36_alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  def generate, do: random_base36(28)

  # Pretty much a blatant ripoff of ActiveSupport's SecureRandom#base36
  defp random_base36(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> :binary.bin_to_list()
    |> Enum.map_join(fn byte ->
      index = rem(byte, 64)
      index = if index >= 36, do: :random.uniform(36) - 1, else: index
      <<Enum.at(@base36_alphabet, index)>>
    end)
  end
end
