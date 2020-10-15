defmodule Upload.Token do
  alias Upload.Utils
  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageVerifier

  def sign(data, salt) do
    secret = get_secret(salt)

    data
    |> :erlang.term_to_binary()
    |> MessageVerifier.sign(secret)
  end

  def verify(token, salt) do
    secret = get_secret(salt)

    with {:ok, message} <- MessageVerifier.verify(token, secret) do
      {:ok, Plug.Crypto.non_executable_binary_to_term(message)}
    end
  end

  defp get_secret(salt) do
    KeyGenerator.generate(Utils.secret_key_base(), to_string(salt))
  end
end
