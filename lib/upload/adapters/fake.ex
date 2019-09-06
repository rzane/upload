defmodule Upload.Adapters.Fake do
  use Upload.Adapter

  @impl true
  def get_url(key) do
    key
  end

  @impl true
  def get_signed_url(key), do: {:ok, get_url(key)}

  @impl true
  def transfer(%Upload{} = upload) do
    {:ok, %Upload{upload | status: :transferred}}
  end
end
