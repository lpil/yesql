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
      source_url: "https://github.com/lpil/yesql",
      docs: docs(),
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/lpil/yesql"},
        files: ~w(LICENCE README.md lib src/Elixir.Yesql.Tokenizer.xrl mix.exs)
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "guides/ecto_configuration.md",
        "guides/postgrex_configuration.md"
      ],
      groups_for_extras: [
        "Configuration": Path.wildcard("guides/*.md")
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
      {:postgrex, "~> 0.15.3", optional: true},
      # Database abstraction
      {:ecto_sql, "~> 3.4", optional: true},
      {:ecto, "~> 3.4.2", optional: true},

      # Automatic testing tool
      {:mix_test_watch, ">= 0.0.0", only: :dev},
      # Documentation generator
      {:ex_doc, "~> 0.21.3", only: :dev}
    ]
  end
end
