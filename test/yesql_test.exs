defmodule YesqlTest do
  use ExUnit.Case
  doctest Yesql
  import TestHelper

  setup_all [:new_postgrex_connection, :create_cats_postgres_table]

  describe "parse/1" do
    import Yesql, only: [parse: 1]

    test "simple tests" do
      assert parse("SELECT * FROM person WHERE age > 18") ==
               {:ok, "SELECT * FROM person WHERE age > 18", []}

      assert parse("SELECT * FROM person WHERE age > :age") ==
               {:ok, "SELECT * FROM person WHERE age > ?", [:age]}

      assert parse("SELECT * FROM person WHERE :age > age") ==
               {:ok, "SELECT * FROM person WHERE ? > age", [:age]}

      assert parse("SELECT 1 FROM dual") == {:ok, "SELECT 1 FROM dual", []}
      assert parse("SELECT :value FROM dual") == {:ok, "SELECT ? FROM dual", [:value]}
      assert parse("SELECT 'test' FROM dual") == {:ok, "SELECT 'test' FROM dual", []}
      assert parse("SELECT 'test'\nFROM dual") == {:ok, "SELECT 'test'\nFROM dual", []}

      assert parse("SELECT :value, :other_value FROM dual") ==
               {:ok, "SELECT ?, ? FROM dual", [:value, :other_value]}
    end

    test "Tokenization rules" do
      assert parse("SELECT :age-5 FROM dual") == {:ok, "SELECT ?-5 FROM dual", [:age]}
    end

    test "escapes" do
      assert parse("SELECT :value, :other_value, ':not_a_value' FROM dual") ==
               {:ok, "SELECT ?, ?, ':not_a_value' FROM dual", [:value, :other_value]}

      assert parse(~S"SELECT 'not \' :a_value' FROM dual") ==
               {:ok, ~S"SELECT 'not \' :a_value' FROM dual", []}
    end

    test "casting" do
      assert parse("SELECT :value, :other_value, 5::text FROM dual") ==
               {:ok, "SELECT ?, ?, 5::text FROM dual", [:value, :other_value]}
    end

    test "newlines are preserved" do
      assert parse("SELECT :value, :other_value, 5::text\nFROM dual") ==
               {:ok, "SELECT ?, ?, 5::text\nFROM dual", [:value, :other_value]}
    end

    test "complex 1" do
      assert parse("SELECT :a+2*:b+age::int FROM users WHERE username = :name AND :b > 0") ==
               {
                 :ok,
                 "SELECT ?+2*?+age::int FROM users WHERE username = ? AND ? > 0",
                 [:a, :b, :name, :b]
               }
    end

    test "complex 2" do
      assert parse("SELECT :value1 + :value2 + value3 + :value4 + :value1\nFROM SYSIBM.SYSDUMMY1") ==
               {
                 :ok,
                 "SELECT ? + ? + value3 + ? + ?\nFROM SYSIBM.SYSDUMMY1",
                 [:value1, :value2, :value4, :value1]
               }
    end

    test "complex 3" do
      assert parse("SELECT ARRAY [:value1] FROM dual") ==
               {:ok, "SELECT ARRAY [?] FROM dual", [:value1]}
    end
  end

  describe "exec/4" do
    setup [:truncate_postgres_cats]

    test "unknown driver" do
      assert_raise Yesql.UnknownDriver, "Unknown database driver Elixir.Boopatron\n", fn ->
        Yesql.exec(self(), Boopatron, "", [], %{})
      end
    end

    test "Postgrex insert", ctx do
      sql = "INSERT INTO cats (age) VALUES ($1)"
      assert {:ok, 1, []} = Yesql.exec(ctx.postgrex, Postgrex, sql, [:age], %{age: 5})
    end

    test "Postgrex insert returning columns", ctx do
      sql = "INSERT INTO cats (age) VALUES ($1), (10) RETURNING age"
      assert {:ok, 2, results} = Yesql.exec(ctx.postgrex, Postgrex, sql, [:age], %{age: 5})
      assert results == [%{age: 5}, %{age: 10}]
    end

    test "Postgrex select", ctx do
      insert_sql = "INSERT INTO cats (age) VALUES ($1), (10)"
      assert {:ok, 2, _} = Yesql.exec(ctx.postgrex, Postgrex, insert_sql, [:age], %{age: 5})
      sql = "SELECT * FROM cats"
      assert {:ok, 2, results} = Yesql.exec(ctx.postgrex, Postgrex, sql, [], %{})
      assert results == [%{age: 5, name: nil}, %{age: 10, name: nil}]
    end

    test "Postgrex invalid insert", ctx do
      insert_sql = "INSERT INTO cats (size) VALUES ($1), (10)"
      assert {:error, error} = Yesql.exec(ctx.postgrex, Postgrex, insert_sql, [:age], %{age: 1})
      assert error.postgres.message == "column \"size\" of relation \"cats\" does not exist"
    end
  end

  describe "defquery/2" do
    use Yesql, driver: Postgrex

    Yesql.defquery("test/sql/select_older_cats.sql")

    test "query function is created" do
      assert function_exported?(__MODULE__, :select_older_cats, 2)
    end

    test "throws if map argument missing" do
      assert_raise Yesql.MissingParam, "Required parameter `:age` not given\n", fn ->
        select_older_cats(nil, %{})
      end
    end

    test "throws if keyword argument missing" do
      assert_raise Yesql.MissingParam, "Required parameter `:age` not given\n", fn ->
        select_older_cats(nil, [])
      end
    end

    # TODO: test query
  end

  # TODO
  # describe "defquery/2 with driver passed"

  # TODO
  # describe "defquery/2 with conn set in use
end
