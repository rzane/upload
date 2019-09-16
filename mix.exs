defmodule Upload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :upload,
      package: package(),
      version: "0.2.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ecto],
        flags: ["-Wunmatched_returns", :error_handling, :race_conditions]
      ],
      aliases: [
        "ecto.setup": ["ecto.create", "ecto.migrate"],
        "ecto.reset": ["ecto.drop", "ecto.setup"]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "ecto.setup": :test,
        "ecto.reset": :test
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 0.0.0"},
      {:mime, "~> 1.2"},
      {:jason, ">= 0.0.0"},
      {:mogrify, "~> 0.7.3", optional: true},
      {:ffmpex, "~> 0.7.0", optional: true},
      {:file_store, ">= 0.0.0", path: "../file_store"},
      {:plug, ">= 0.0.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ecto_sql, ">= 0.0.0", only: :test},
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
