defmodule Upload.Key do
  alias Upload.Config

  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier

  @type t() :: binary()

  @base36_alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: t()
  def generate, do: random_base36(28)

  @spec generate_variant(t(), t()) :: t()
  def generate_variant(blob_key, transform_key) do
    "variants/#{blob_key}/#{hexdigest(transform_key)}"
  end

  @spec sign(term(), atom()) :: t()
  def sign(data, purpose) do
    data
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(get_secret(purpose))
  end

  @spec verify(binary(), atom()) :: {:ok, term()} | :error
  def verify(token, purpose) do
    with {:ok, message} <- MessageVerifier.verify(token, get_secret(purpose)) do
      {:ok, Plug.Crypto.safe_binary_to_term(message)}
    end
  end

  defp get_secret(purpose) do
    KeyGenerator.generate(Config.secret(), to_string(purpose))
  end

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end

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
