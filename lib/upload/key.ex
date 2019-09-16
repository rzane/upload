defmodule Upload.Key do
  alias Upload.Config

  @base36_alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: binary
  def generate, do: random_base36(28)

  @spec generate_variant(binary(), binary()) :: binary()
  def generate_variant(key, variation) do
    "variants/#{key}/#{hexdigest(variation)}"
  end

  @spec encode(map()) :: binary()
  def encode(transforms) do
    Joken.generate_and_sign!(%{}, transforms, token_signer())
  end

  @spec decode(binary()) :: {:ok, map()} | {:error, Joken.error_reason()}
  def decode(token) do
    Joken.verify_and_validate(%{}, token, token_signer())
  end

  defp token_signer do
    Joken.Signer.create("HS256", Config.secret())
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
end
