defmodule Upload.Key do
  alias Upload.Config

  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier

  @base36_alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: binary
  def generate, do: random_base36(28)

  @spec generate_variant(binary(), binary()) :: binary()
  def generate_variant(key, variation) do
    "variants/#{key}/#{hexdigest(variation)}"
  end

  @spec sign(map(), atom()) :: binary()
  def sign(data, purpose) do
    data
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(get_secret(purpose))
  end

  @spec verify(binary(), atom()) :: {:ok, map()} | :error
  def verify(token, purpose) do
    with {:ok, message} <- MessageVerifier.verify(token, get_secret(purpose)) do
      {:ok, Plug.Crypto.safe_binary_to_term(message)}
    end
  end

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end

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

  defp get_secret(purpose) do
    KeyGenerator.generate(Config.secret(), to_string(purpose))
  end
end
