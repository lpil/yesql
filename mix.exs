defmodule Yesql.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yesql,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:mix_test_watch, ">= 0.0.0", only: :dev},
      {:postgrex, "~> 0.12", only: [:dev, :test]},
    ]
  end
end
