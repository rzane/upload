use Mix.Config

config :logger, level: :info

config :upload,
  log: false,
  secret_key: "sup3r_secret",
  ecto_repos: [Upload.Test.Repo]

config :upload, Upload.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "upload_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"

config :upload, Upload.Storage,
  adapter: FileStore.Adapters.Memory,
  base_url: "http://example.com"
