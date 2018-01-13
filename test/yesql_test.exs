defmodule YesqlTest do
  use ExUnit.Case
  doctest Yesql

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
end
