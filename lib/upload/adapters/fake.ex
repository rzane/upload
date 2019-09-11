defmodule Upload.Adapters.Fake do
  @moduledoc """
  An `Upload.Adapter` that doesn't actually store files.
  """

  use Upload.Adapter

  @impl true
  def get_url(key) do
    key
  end

  @impl true
  def get_signed_url(key, _opts), do: {:ok, get_url(key)}

  @impl true
  def transfer(%Upload{} = upload) do
    {:ok, %Upload{upload | status: :transferred}}
  end
end
