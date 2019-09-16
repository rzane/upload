defmodule Upload.Config do
  @moduledoc false

  @spec table_name() :: binary()
  def table_name do
    Application.get_env(:upload, :table_name, "upload_blobs")
  end

  @spec secret() :: binary()
  def secret do
    Application.fetch_env!(:upload, :secret)
  end

  @spec log_level() :: atom()
  def log_level do
    Application.get_env(:upload, :log_level, :info)
  end

  @spec file_store() :: FileStore.t()
  def file_store do
    case Application.get_env(:upload, :file_store, []) do
      {module, function_name} ->
        apply(module, function_name, [])

      config ->
        FileStore.new(config)
    end
  end
end
