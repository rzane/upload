defmodule Upload.Key do
  @type t() :: binary()

  @key_length 28
  @alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: t()
  def generate() do
    @key_length
    |> :crypto.strong_rand_bytes()
    |> :binary.bin_to_list()
    |> Enum.map_join(&base36(rem(&1, 64)))
  end

  for {digit, index} <- Enum.with_index(@alphabet) do
    defp base36(unquote(index)), do: <<unquote(digit)>>
  end

  defp base36(_), do: base36(:random.uniform(36) - 1)
end
