defmodule RhymeThyme.RhymeEngine do
  alias RhymeThyme.Trie
  @external_resource "cmudict-0.7b"

  @data File.stream!(@external_resource)
    |> Stream.reject(&String.starts_with?(&1, ";;;"))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "  ", parts: 2))
    # |> Enum.take(8_000)
    |> Enum.reduce(
      {Trie.new(), Trie.new()},
      fn [word, pro], {pro_trie, rhyme_trie} ->
        # word = String.replace(word, ~r/\(\d+\)/, "")
        if String.printable?(word) do
          letters = String.graphemes(word)
          reversed_phones = pro |> String.split |> Enum.reverse
          {
            Trie.insert(pro_trie, letters, pro),
            Trie.insert(rhyme_trie, reversed_phones, word)
          }
        else
          { pro_trie, rhyme_trie }
        end
      end
    )

  def data, do: @data

  def pronunciation(word) do
    {pro, _rhyme} = @data
    Trie.lookup(pro, String.graphemes(String.upcase(word)))
  end

  def rhymes_with(word) do
    {pro, rhyme} = @data
    word = String.upcase(word)
    case Trie.lookup(pro, String.graphemes(word)) do
      nil -> []
      found_pro ->
        [last_syllable|optional] =
          found_pro
          |> String.split
          |> Enum.reverse
          |> Enum.chunk_while([], &chunk_fn/2, &after_fn/1)
          |> IO.inspect(label: "syllables")
        rhyme
        |> Trie.values(last_syllable, List.flatten(optional))
        |> Enum.reject(fn ^word -> true; _ -> false end)
    end
  end

  defp chunk_fn(item, acc) do
    if String.length(item) == 3 do
      {:cont, Enum.reverse([item|acc]), []}
    else
      {:cont, [item|acc]}
    end
  end

  defp after_fn([]), do: {:cont, []}
  defp after_fn(acc), do: {:cont, Enum.reverse(acc), []}
end
