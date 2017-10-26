# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :upload, Upload,
  adapter: Upload.Adapters.Local

config :upload, Upload.Adapters.S3,
  bucket: "my_bucket_name"

# Point ex_aws at local fakes3
config :ex_aws,
  access_key_id: ["foo", :instance_role],
  secret_access_key: ["bar", :instance_role]

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 4569,
  region: "us-east-1"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :upload, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:upload, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
