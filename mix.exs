defmodule Upload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :upload,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:plug, ">= 0.0.0"},

      # S3 Adapter
      {:ex_aws, "~> 1.1", optional: true},
      {:hackney, "1.6.3 or 1.6.5 or 1.7.1 or 1.8.6 or ~> 1.9", optional: true},
      {:poison, ">= 1.2.0", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},

      # Ecto integration
      {:ecto, ">= 0.0.0", optional: true},

      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      "fakes3": &fakes3/1
    ]
  end

  defp fakes3(_) do
    Mix.shell.cmd("docker run --rm -p 4569:4569 lphoward/fake-s3")
  end
end
