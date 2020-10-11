use Mix.Config

config :upload, Upload.Storage,
  adapter: FileStore.Adapters.Memory,
  base_url: "http://example.com"
