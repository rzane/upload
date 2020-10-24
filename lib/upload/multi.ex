defmodule Upload.Multi do
  alias Upload.Blob
  alias Upload.Storage

  alias Ecto.Multi
  alias Ecto.Association.NotLoaded

  @doc """
  Upload a blob to storage.
  """
  @spec upload(Multi.t(), Multi.name(), Blob.t()) :: Multi.t()
  def upload(multi, name, %Blob{key: key, path: path} = blob)
      when is_binary(key) and is_binary(path) do
    Multi.run(multi, name, fn _repo, _ctx -> do_upload(blob) end)
  end

  @spec upload(Multi.t(), Multi.name(), Multi.fun(Blob.t())) :: Multi.t()
  def upload(multi, name, fun) when is_function(fun) do
    Multi.run(multi, name, fn _repo, ctx -> ctx |> fun.() |> do_upload() end)
  end

  defp do_upload(nil), do: {:ok, nil}
  defp do_upload(%NotLoaded{} = blob), do: {:ok, blob}
  defp do_upload(%Blob{path: nil} = blob), do: {:ok, blob}

  defp do_upload(%Blob{path: path, key: key} = blob) when is_binary(key) do
    with :ok <- Storage.upload(path, key),
         do: {:ok, blob}
  end

  @doc """
  Remove a blob and it's variants from storage.
  """
  @spec purge(Multi.t(), Multi.name(), Blob.t()) :: Multi.t()
  def purge(multi, name, %Blob{key: key} = blob) when is_binary(key) do
    Multi.run(multi, name, fn _repo, _ctx -> do_purge(blob) end)
  end

  @spec purge(Multi.t(), Multi.name(), Multi.fun(Blob.t())) :: Multi.t()
  def purge(multi, name, fun) when is_function(fun) do
    Multi.run(multi, name, fn _repo, ctx -> ctx |> fun.() |> do_purge() end)
  end

  defp do_purge(nil), do: {:ok, nil}

  defp do_purge(%Blob{key: key} = blob) when is_binary(key) do
    with :ok <- Storage.delete_all(prefix: "variants/#{key}/"),
         :ok <- Storage.delete(key),
         do: {:ok, blob}
  end
end
