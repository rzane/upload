defmodule Upload.Adapters.Test do
  use Upload.Adapter
  use Agent

  @moduledoc """
  An `Upload.Adapter` that keeps track of uploaded files in memory, so that
  you can make assertions.

  ### Example

      test "files are uploaded" do
        assert {:ok, _} = start_supervised(Upload.Adapters.Test)
        assert {:ok, upload} = Upload.cast_path("/path/to/file.txt")
        assert {:ok, upload} = Upload.transfer(upload)
        assert Map.size(Upload.Adapters.Test.get_uploads()) == 1
      end

  """

  @doc """
  Starts and agent for the test adapter.
  """
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Stops the agent for the test adapter.
  """
  def stop(reason \\ :normal, timeout \\ :infinity) do
    Agent.stop(__MODULE__, reason, timeout)
  end

  @doc """
  Get all uploads.
  """
  def get_uploads do
    Agent.get(__MODULE__, fn state -> state end)
  end

  @doc """
  Add an upload to the state.
  """
  def put_upload(upload) do
    Agent.update(__MODULE__, &Map.put(&1, upload.key, upload))
  end

  @impl true
  def get_url(key), do: key

  @impl true
  def get_signed_url(key, _opts), do: {:ok, get_url(key)}

  @impl true
  def transfer(%Upload{} = upload) do
    upload = %Upload{upload | status: :transferred}
    put_upload(upload)
    {:ok, upload}
  end
end
