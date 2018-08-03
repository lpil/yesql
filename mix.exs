defmodule Yesql.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yesql,
      version: "0.3.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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
    case Mix.env() do
      :test ->
        [
          mod: {YesqlTest.Application, []},
          extra_applications: [:logger, :runtime_tools]
        ]

      _ ->
        [extra_applications: []]
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Postgresql driver
      {:postgrex, "~> 0.12", optional: true},
      # Database abstraction
      {:ecto, "~> 2.0", optional: true},

      # Automatic testing tool
      {:mix_test_watch, ">= 0.0.0", only: :dev},
      # Documentation generator
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end
end
