defmodule Yesql do
  @moduledoc """
  Documentation for Yesql.
  """

  defmodule UnknownDriver do
    defexception [:message]

    def exception(driver) do
      %__MODULE__{message: "Unknown database driver #{driver}"}
    end
  end

  @doc false
  def parse(sql) do
    extract_param = fn
      param, {sql, params} when is_atom(param) ->
        {[sql, "?"], [param | params]}

      fragment, {sql, params} ->
        {[sql, fragment], params}
    end

    merge_fragments = fn
      [{:fragment, _} | _] = tokens ->
        tokens
        |> Keyword.values()
        |> IO.iodata_to_binary()
        |> List.wrap()

      tokens ->
        Keyword.values(tokens)
    end

    with {:ok, tokens, _} <- Yesql.Tokenizer.tokenize(sql) do
      {query_iodata, rev_params} =
        tokens
        |> Enum.chunk_by(&elem(&1, 0))
        |> Enum.flat_map(merge_fragments)
        |> Enum.reduce({[], []}, extract_param)

      {:ok, IO.iodata_to_binary(query_iodata), Enum.reverse(rev_params)}
    end
  end

  @doc false
  def exec(conn, driver, sql, params, data) do
    param_list = Enum.map(params, &Map.fetch!(data, &1))

    with {:ok, result} <- exec_for_driver(conn, driver, sql, param_list) do
      format_result(result)
    end
  end

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
