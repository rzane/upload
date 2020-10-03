defmodule Upload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :upload,
      package: package(),
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ecto, :ex_aws],
        flags: ["-Wunmatched_returns", :error_handling, :race_conditions]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp package do
    [
      description: "An opinionated file uploader",
      files: ["lib", "config", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["Ray Zane"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rzane/upload"}
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
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:hackney, ">= 0.0.0", optional: true},
      {:sweet_xml, ">= 0.0.0", optional: true},

      # Ecto integration
      {:ecto, ">= 0.0.0", optional: true},

      # Test dependencies for this package
      {:excoveralls, "~> 0.13", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
