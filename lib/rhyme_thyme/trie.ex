defmodule RhymeThyme.Trie do
  def new, do: {nil, %{}}

  def insert(trie, [], value), do: put_elem(trie, 0, value)
  def insert({_, sub} = trie, [letter | rest], value) do
    case sub[letter] do
      nil ->
        put_elem(trie, 1, Map.put(sub, letter, insert(new(), rest, value)))
      node ->
        put_elem(trie, 1, Map.put(sub, letter, insert(node, rest, value)))
    end
  end

  def lookup({value, _}, []), do: value
  def lookup({_, sub}, [letter | rest]) do
    case sub[letter] do
      nil -> nil
      node -> lookup(node, rest)
    end
  end

  defp values_recurse(nil, _), do: []
  defp values_recurse({val, sub}, [current|next]) do
    preferred_path = sub[current]
    preferred_vals = values_recurse(preferred_path, next)
    other_vals =
      sub
      |> Map.delete(current)
      |> Map.values
      |> Enum.flat_map(&values_recurse(&1, []))

    case val do
      nil -> preferred_vals ++ other_vals
      val -> preferred_vals ++ [val|other_vals]
    end
  end
  defp values_recurse({val, sub}, []) do
    sub_vals =
      sub
      |> Map.values
      |> Enum.flat_map(&values_recurse(&1, []))

    case val do
      nil -> sub_vals
      val -> [val|sub_vals]
    end

  end

  def values(trie, prefix, optional) do
    trie
    |> find_sub(prefix)
    |> values_recurse(optional)
  end

  defp find_sub(trie, []), do: trie
  defp find_sub({_, sub}, [first | rest]) do
    case sub[first] do
      nil -> nil
      node -> find_sub(node, rest)
    end
  end
end
