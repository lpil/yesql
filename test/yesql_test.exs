defmodule YesqlTest do
  use ExUnit.Case
  doctest Yesql

  describe "parse/1" do
    def input >>> output do
      assert Yesql.parse(input) == {:ok, output}
    end

    test "simple tests" do
      "SELECT * FROM person WHERE age > 18" >>> ["SELECT * FROM person WHERE age > 18"]
      "SELECT * FROM person WHERE age > :age" >>> ["SELECT * FROM person WHERE age > ", :age]
      "SELECT * FROM person WHERE :age > age" >>> ["SELECT * FROM person WHERE ", :age, " > age"]
      "SELECT 1 FROM dual" >>> ["SELECT 1 FROM dual"]
      "SELECT :value FROM dual" >>> ["SELECT ", :value, " FROM dual"]
      "SELECT 'test' FROM dual" >>> ["SELECT 'test' FROM dual"]
      "SELECT 'test'\nFROM dual" >>> ["SELECT 'test'\nFROM dual"]

      "SELECT :value, :other_value FROM dual" >>>
        ["SELECT ", :value, ", ", :other_value, " FROM dual"]
    end

    test "Tokenization rules" do
      "SELECT :age-5 FROM dual" >>> ["SELECT ", :age, "-5 FROM dual"]
    end

    test "escapes" do
      "SELECT :value, :other_value, ':not_a_value' FROM dual" >>>
        ["SELECT ", :value, ", ", :other_value, ", ':not_a_value' FROM dual"]

      ~S"SELECT 'not \' :a_value' FROM dual" >>> [~S"SELECT 'not \' :a_value' FROM dual"]
    end

    test "casting" do
      "SELECT :value, :other_value, 5::text FROM dual" >>>
        ["SELECT ", :value, ", ", :other_value, ", 5::text FROM dual"]
    end

    test "newlines are preserved" do
      "SELECT :value, :other_value, 5::text\nFROM dual" >>>
        ["SELECT ", :value, ", ", :other_value, ", 5::text\nFROM dual"]
    end

    test "complex 1" do
      "SELECT :a+2*:b+age::int FROM users WHERE username = :name AND :b > 0" >>>
        [
          "SELECT ",
          :a,
          "+2*",
          :b,
          "+age::int FROM users WHERE username = ",
          :name,
          " AND ",
          :b,
          " > 0"
        ]
    end

    test "complex 2" do
      "SELECT :value1 + :value2 + value3 + :value4 + :value1\nFROM SYSIBM.SYSDUMMY1" >>>
        [
          "SELECT ",
          :value1,
          " + ",
          :value2,
          " + value3 + ",
          :value4,
          " + ",
          :value1,
          "\nFROM SYSIBM.SYSDUMMY1"
        ]
    end

    test "complex 3" do
      "SELECT ARRAY [:value1] FROM dual" >>> ["SELECT ARRAY [", :value1, "] FROM dual"]
    end
  end
end
