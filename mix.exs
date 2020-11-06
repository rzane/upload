defmodule Upload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :upload,
      package: package(),
      version: "0.0.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ecto, :ex_aws, :ex_aws_s3],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
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
      {:ecto, "~> 3.0"},
      {:file_store, "~> 0.2"},
      {:file_type, "~> 0.1"},
      {:mime, "~> 1.2"},
      {:plug, "~> 1.0"},

      # Test dependencies for this package
      {:jason, ">= 0.0.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ecto_sql, ">= 0.0.0", only: :test},
      {:excoveralls, "~> 0.13", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
