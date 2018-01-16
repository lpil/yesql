defmodule Yesql do
  @moduledoc """
  Documentation for Yesql.
  """

  alias __MODULE__.{NoDriver, UnknownDriver, MissingParam}

  @supported_drivers [Postgrex]

  defmacro __using__(opts) do
    quote bind_quoted: binding() do
      @yesql_private__driver opts[:driver]
    end
  end

  defmacro defquery(file_path, opts \\ []) do
    drivers = @supported_drivers

    quote bind_quoted: binding() do
      name = file_path |> Path.basename(".sql") |> String.to_atom()
      driver = opts[:driver] || @yesql_private__driver || raise(NoDriver, name)

      unless driver in drivers, do: raise(UnknownDriver, driver)

      {:ok, sql, param_spec} = file_path |> File.read!() |> Yesql.parse()

      def unquote(name)(conn, args) do
        Yesql.exec(conn, unquote(driver), unquote(sql), unquote(param_spec), args)
      end
    end
  end

  @doc false
  def parse(sql) do
    extract_param = fn
      {:named_param, param}, {sql, params} ->
        {[sql, "?"], [param | params]}

      {:fragment, fragment}, {sql, params} ->
        {[sql, fragment], params}
    end

    with {:ok, tokens, _} <- Yesql.Tokenizer.tokenize(sql) do
      {query_iodata, rev_params} =
        tokens
        |> Enum.reduce({[], []}, extract_param)

      sql = IO.iodata_to_binary(query_iodata)
      {:ok, sql, Enum.reverse(rev_params)}
    end
  end

  @doc false
  def exec(conn, driver, sql, param_spec, data) do
    param_list = Enum.map(param_spec, &fetch_param(data, &1))

    with {:ok, result} <- exec_for_driver(conn, driver, sql, param_list) do
      format_result(result)
    end
  end

  defp fetch_param(data, key) do
    case dict_fetch(data, key) do
      {:ok, value} -> value
      :error -> raise(MissingParam, key)
    end
  end

  defp dict_fetch(dict, key) when is_map(dict), do: Map.fetch(dict, key)
  defp dict_fetch(dict, key) when is_list(dict), do: Keyword.fetch(dict, key)

  if Code.ensure_compiled?(Postgrex) do
    defp exec_for_driver(conn, Postgrex, sql, param_list) do
      Postgrex.query(conn, sql, param_list)
    end
  end

  defp exec_for_driver(_, driver, _, _) do
    raise UnknownDriver.exception(driver)
  end

  defp format_result(result) do
    atom_columns = Enum.map(result.columns || [], &String.to_atom/1)

    return =
      Enum.map(result.rows || [], fn row ->
        atom_columns |> Enum.zip(row) |> Enum.into(%{})
      end)

    {:ok, result.num_rows, return}
  end
end
