defmodule Upload.Key do
  alias Upload.Blob
  alias Upload.Variant
  alias Upload.Utils

  @key_length 28
  @alphabet '0123456789abcdefghijklmnopqrstuvwxyz'

  @spec generate() :: binary
  def generate do
    @key_length
    |> :crypto.strong_rand_bytes()
    |> :binary.bin_to_list()
    |> Enum.map_join(&base36(rem(&1, 64)))
  end

  @spec generate(Variant.t()) :: binary
  def generate(%Variant{blob: blob, transforms: transforms}) do
    signed_transforms = do_sign(transforms, "transforms")
    "variants/#{blob.key}/#{hexdigest(signed_transforms)}"
  end

  @spec sign(Blob.t()) :: binary
  def sign(%Blob{id: id}) do
    do_sign(id, "blob")
  end

  @spec sign(Variant.t()) :: {binary, binary}
  def sign(%Variant{blob: blob, transforms: transforms}) do
    {sign(blob), do_sign(transforms, "transforms")}
  end

  @spec verify(binary) :: {:ok, Blob.t()} | :error
  def verify(signed_blob) do
    repo = Utils.repo()

    with {:ok, blob_id} <- do_verify(signed_blob, "blob") do
      case repo.get(Blob, blob_id) do
        nil -> :error
        blob -> {:ok, blob}
      end
    end
  end

  @spec verify(binary, binary) :: {:ok, Variant.t()} | :error
  def verify(signed_blob, signed_transforms) do
    with {:ok, transforms} <- do_verify(signed_transforms, "transforms"),
         {:ok, blob} <- verify(signed_blob) do
      {:ok, Variant.new(blob, transforms)}
    end
  end

  defp do_sign(data, salt) do
    Plug.Crypto.sign(Utils.secret_key_base(), salt, data)
  end

  defp do_verify(token, salt) do
    Plug.Crypto.verify(Utils.secret_key_base(), salt, token)
  end

  defp hexdigest(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16() |> String.downcase()
  end

  for {digit, index} <- Enum.with_index(@alphabet) do
    defp base36(unquote(index)), do: <<unquote(digit)>>
  end

  defp base36(_), do: base36(:random.uniform(36) - 1)
end
