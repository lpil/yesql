defmodule Yesql.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yesql,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Yesql",
      description: "Using plain old SQL to query databases",
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/lpil/yesql"},
        files: ~w(LICENCE README.md lib src/Elixir.Yesql.Tokenizer.xrl mix.exs)
      ]
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      # Postgresql driver
      {:postgrex, "~> 0.12", optional: true},
      # Automatic testing tool
      {:mix_test_watch, ">= 0.0.0", only: :dev},
      # Documentation generator
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end
end
