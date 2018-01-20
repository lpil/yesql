{:ok, _} = Application.ensure_all_started(:postgrex)
ExUnit.start()

defmodule TestHelper do
  def new_postgrex_connection(ctx) do
    opts = [
      hostname: "localhost",
      username: "postgres",
      password: "postgres",
      database: "yesql_test",
      name: Module.concat(ctx.module, Postgrex)
    ]

    {:ok, conn} = Postgrex.start_link(opts)
    {:ok, postgrex: conn}
  end

  def create_cats_postgres_table(ctx) do
    drop_sql = """
    DROP TABLE IF EXISTS cats;
    """

    create_sql = """
    CREATE TABLE cats (
      age  integer NOT NULL,
      name varchar
    );
    """

    Postgrex.query!(ctx.postgrex, drop_sql, [])
    Postgrex.query!(ctx.postgrex, create_sql, [])
    :ok
  end

  def truncate_postgres_cats(ctx) do
    Postgrex.query!(ctx.postgrex, "TRUNCATE cats", [])
    :ok
  end
end
