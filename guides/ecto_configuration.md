# Ecto

## Install dependencies

We only need the `postgrex` and `ecto_sql` dependencies, but it doesn't hurt
to also add `ecto`:

```elixir
defp deps do
  [
    {:postgrex, "~> 0.15.4"},
    {:ecto_sql, "~> 3.4"},
    {:ecto, "~> 3.4"},
    {:yesql, "~> 1.0"}
  ]
end
```

## Start ecto process

At the ecto docs we can find an excellent [configuration guide](https://hexdocs.pm/ecto/Ecto.html#module-repositories)
for adding ecto to your project.

First we declare our Repo module:

```elixir
defmodule Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
end
```

And add it to our supervision tree:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    conn_params = [
      name: MyApp.Repo,
      hostname: "host", username: "user", password: "pass", database: "your_db"
    ]

    children = [
      {Repo, conn_params},
    ]

    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
```

## Declare in yesql

Then declare your yesql module by specifying you want to use ecto
along with the ecto process:

```elixir
defmodule Query do
  use Yesql, driver: Ecto, conn: MyApp.Repo

  Yesql.defquery("some/where/now.sql")
  Yesql.defquery("some/where/select_users.sql")
  Yesql.defquery("some/where/select_users_by_country.sql")
end

Query.now []
# => {:ok, [%{now: ~U[2020-05-09 21:22:54.680122Z]}]}

Query.users_by_country(country_code: "gbr")
# => {:ok, [%{name: "Louis", country_code: "gbr"}]}
```
