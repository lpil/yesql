# Postgrex

## Install dependencies

Add both dependencies in your `mix.exs` file:

```elixir
  defp deps do
    [
      {:postgrex, "~> 0.15.4"},
      {:yesql, "~> 1.0"}
    ]
  end
```

## Start postgrex process

Althought it cna be [started manually](https://hexdocs.pm/postgrex/readme.html#example),
it is a good idea to declare this process inside a supervision tree
along with a name we can easily reference later.

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    conn_params = [
      name: ConnectionPool,
      hostname: "host", username: "user", password: "pass", database: "your_db"
    ]

    children = [
      {Postgrex, conn_params},
    ]

    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
```

## Declare in yesql

Then declare your yesql module by specifying you want to use postgrex
along with the postgrex process:

```elixir
    defmodule Query do
      use Yesql, driver: Postgrex, conn: ConnectionPool

      Yesql.defquery("some/where/now.sql")
      Yesql.defquery("some/where/select_users.sql")
      Yesql.defquery("some/where/select_users_by_country.sql")
    end

    Query.now []
    # => {:ok, [%{now: ~U[2020-05-09 21:22:54.680122Z]}]}

    Query.users_by_country(country_code: "gbr")
    # => {:ok, [%{name: "Louis", country_code: "gbr"}]}
```
