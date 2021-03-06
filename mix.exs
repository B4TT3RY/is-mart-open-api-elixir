defmodule IsMartOpenApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :is_mart_open_api,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {IsMartOpenApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 1.8"},
      {:timex, "~> 3.7"},
      {:jason, "~> 1.2"},
      {:floki, "~> 0.31.0"}
    ]
  end
end
