defmodule Upload.DataCase do
  use ExUnit.CaseTemplate

  alias Upload.Test.Repo
  alias FileStore.Adapters.Memory

  using do
    quote do
      import Ecto.Changeset
      import Upload.DataCase
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, _} = start_supervised(Memory)
    :ok
  end

  def get_upload_count do
    Enum.count(Upload.Storage.list!())
  end

  def fixture_path(name) do
    "../fixtures"
    |> Path.expand(__DIR__)
    |> Path.join(name)
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
