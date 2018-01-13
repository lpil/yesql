defmodule Yesql do
  @moduledoc """
  Documentation for Yesql.
  """

  @doc false
  def parse(sql) do
    with {:ok, tokens, _} <- Yesql.Tokenizer.tokenize(sql) do
      {query_iodata, rev_params} =
        tokens
        |> Enum.chunk_by(&elem(&1, 0))
        |> Enum.flat_map(&merge_fragments/1)
        |> Enum.reduce({[], []}, &extract_param/2)

      {:ok, IO.iodata_to_binary(query_iodata), Enum.reverse(rev_params)}
    end
  end

  defp extract_param(param, {sql, params}) when is_atom(param) do
    {[sql, "?"], [param | params]}
  end

  defp extract_param(fragment, {sql, params}) do
    {[sql, fragment], params}
  end

  defp merge_fragments([{:fragment, _} | _] = tokens) do
    tokens
    |> Keyword.values()
    |> IO.iodata_to_binary()
    |> List.wrap()
  end

  defp merge_fragments(tokens) do
    Keyword.values(tokens)
  end
end
