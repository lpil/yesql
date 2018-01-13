defmodule Yesql do
  @moduledoc """
  Documentation for Yesql.
  """

  @doc false
  def parse(sql) do
    with {:ok, tokens, _} <- Yesql.Tokenizer.tokenize(sql) do
      output =
        tokens
        |> Enum.chunk_by(&elem(&1, 0))
        |> Enum.flat_map(&merge_fragments/1)

      {:ok, output}
    end
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
