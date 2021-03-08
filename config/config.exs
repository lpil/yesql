use Mix.Config

case Mix.env() do
  :test ->
    config :yesql, ecto_repos: [YesqlTest.Repo]

    config :yesql, YesqlTest.Repo,
      username: "postgres",
      password: "postgres",
      database: "yesql_test",
      hostname: "localhost"

    config :logger, level: :info

  _ ->
    :ok
end

# Config custom drivers in your projects config! Pattern:
#
 config :yesql,
  custom_yesql_drivers: [#Mssqlex,
                        ]
