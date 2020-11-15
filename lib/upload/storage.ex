defmodule Upload.Storage do
  alias FileStore.Middleware.Errors

  use FileStore.Config, otp_app: :upload

  def init(config) do
    Keyword.update(config, :middleware, [Errors], fn middleware ->
      if Errors in middleware do
        middleware
      else
        [Errors] ++ middleware
      end
    end)
  end
end
