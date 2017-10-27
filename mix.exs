defmodule Upload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :upload,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:ecto, :ex_aws]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:httpoison, "~> 0.11", optional: true},
      {:ex_aws, "~> 1.1", optional: true},
      {:poison, "~> 2.2 or ~> 3.1", optional: true},
      {:sweet_xml, "~> 0.6", optional: true},

      # Ecto integration
      {:ecto, ">= 0.0.0", optional: true},

      {:exvcr, "~> 0.8", only: :test},
      {:excoveralls, "~> 0.7", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
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
