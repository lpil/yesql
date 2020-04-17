defmodule YesqlTest.Application do
  use Application

  def start(_type, _args) do
    Application.ensure_all_started(:ecto)
    Application.ensure_all_started(:postgrex)
    Supervisor.start_link([YesqlTest.Repo], strategy: :one_for_one, name: Blondie.Supervisor)
  end
end

defmodule YesqlTest.Repo do
  use Ecto.Repo,
    otp_app: :yesql,
    adapter: Ecto.Adapters.Postgres
end
