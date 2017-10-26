defmodule Upload.Adapters.Fake do
  use Upload.Adapter

  @impl true
  def get_url(key) do
    key
  end

  @impl true
  def transfer(%Upload{key: key, path: path} = upload) do
    {:ok, %Upload{upload | status: :completed}}
  end
end
