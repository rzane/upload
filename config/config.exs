use Mix.Config

config :logger, level: :info

# Configuration for the test suite
config :upload, ecto_repos: [Upload.Test.Repo]

config :upload, Upload.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "upload_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"

# Configuration for this package
config :upload,
  log: false,
  repo: Upload.Test.Repo,
  secret_key_base: "super secret",
  metadata: [Upload.Stat.Image, Upload.Stat.Video]

config :upload, Upload.Storage,
  adapter: FileStore.Adapters.Memory,
  base_url: "http://example.com"
