defmodule Yesql do
  @moduledoc """

      defmodule Query do
        use Yesql, driver: Postgrex, conn: MyApp.ConnectionPool

        Yesql.defquery("some/where/select_users_by_country.sql")
      end

      Query.users_by_country(country_code: "gbr")
      # => {:ok, [%{name: "Louis", country_code: "gbr"}]}

  ## Supported drivers

  - `Postgrex`
  - `Ecto`, for which `conn` is an Ecto repo.

  ## Configuration

  Checkout the [Postgrex](postgrex_configuration.html) or
  [Ecto](ecto_configuration.html) configuration guides.

  """

  alias __MODULE__.{NoDriver, UnknownDriver, MissingParam}

  @supported_drivers [Postgrex, Ecto]

  defmacro __using__(opts) do
    quote bind_quoted: binding() do
      @yesql_private__driver opts[:driver]
      @yesql_private__conn opts[:conn]
    end
  end

  defmacro defquery(file_path, opts \\ []) do
    drivers = @supported_drivers

    quote bind_quoted: binding() do
      name = file_path |> Path.basename(".sql") |> String.to_atom()
      driver = opts[:driver] || @yesql_private__driver || raise(NoDriver, name)
      conn = opts[:conn] || @yesql_private__conn

      {:ok, sql, param_spec} =
        file_path |> File.read!() |> String.replace("\r\n", "\n") |> Yesql.parse()

      unless driver in drivers, do: raise(UnknownDriver, driver)

      def unquote(name)(conn, args) do
        Yesql.exec(conn, unquote(driver), unquote(sql), unquote(param_spec), args)
      end

      if conn do
        def unquote(name)(args) do
          Yesql.exec(unquote(conn), unquote(driver), unquote(sql), unquote(param_spec), args)
        end
      end
    end
  end

  @doc false
  def parse(sql) do
    with {:ok, tokens, _} <- Yesql.Tokenizer.tokenize(sql) do
      {_, query_iodata, params_pairs} =
        tokens
        |> Enum.reduce({1, [], []}, &extract_param/2)

      sql = IO.iodata_to_binary(query_iodata)
      params = params_pairs |> Keyword.keys() |> Enum.reverse()

      {:ok, sql, params}
    end
  end

  defp extract_param({:named_param, param}, {i, sql, params}) do
    case params[param] do
      nil ->
        {i + 1, [sql, "$#{i}"], [{param, i} | params]}

      num ->
        {i, [sql, "$#{num}"], params}
    end
  end

  defp extract_param({:fragment, fragment}, {i, sql, params}) do
    {i, [sql, fragment], params}
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

  is_compiled? = fn module -> match?({:module, ^module}, Code.ensure_compiled(module)) end

  if is_compiled?.(Postgrex) do
    defp exec_for_driver(conn, Postgrex, sql, param_list) do
      Postgrex.query(conn, sql, param_list)
    end
  end

  if is_compiled?.(Ecto) do
    defp exec_for_driver(repo, Ecto, sql, param_list) do
      Ecto.Adapters.SQL.query(repo, sql, param_list)
    end
  end

  defp exec_for_driver(_, driver, _, _) do
    raise UnknownDriver.exception(driver)
  end

  defp format_result(result) do
    atom_columns = Enum.map(result.columns || [], &String.to_atom/1)

    result =
      Enum.map(result.rows || [], fn row ->
        atom_columns |> Enum.zip(row) |> Enum.into(%{})
      end)

    {:ok, result}
  end
end
