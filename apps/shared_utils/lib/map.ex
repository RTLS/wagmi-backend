defmodule SharedUtils.Map do
  @moduledoc """
  A utility module to make it easier to work with maps
  """

  @spec apply_defaults(map(), map()) :: map()
  @doc """
  Merges default options onto a map.
  Basically just `Map.merge/2` with flipped args, for convenient usage in pipes.

  ### Example

    iex> SharedUtils.Map.apply_defaults(%{a: 1, b: 2}, %{a: 3, c: 4})
    %{a: 1, b: 2, c: 4}
  """
  def apply_defaults(map, defaults), do: Map.merge(defaults, map)

  @spec merge_deep_left(map(), map()) :: map()
  @doc """
  Merges two maps and preserves nested map structure keeping items in the left arg

  ### Example

    iex> SharedUtils.Map.merge_deep_left(%{a: 1, c: %{c: 3, d: 4}}, %{a: 3, b: 2, c: %{c: 4, e: 5}})
    %{a: 1, b: 2, c: %{c: 3, d: 4, e: 5}}
  """
  def merge_deep_left(map_a, map_b) do
    Map.merge(map_a, map_b, fn
      _k, left, right when is_map(left) and is_map(right) -> merge_deep_left(left, right)
      _, left, _ -> left
    end)
  end

  @spec has_any_keys?(map(), list(any)) :: boolean
  @doc """
  Checks to see if a map has any of the keys

  ### Example

    iex> SharedUtils.Map.has_any_keys?(%{a: 1, b: 3, c: 34}, [:a])
    true
    iex> SharedUtils.Map.has_any_keys?(%{a: 1, b: 3, c: 3}, [:c])
    true
    iex> SharedUtils.Map.has_any_keys?(%{a: 1, b: 3, c: 3}, [:r])
    false
  """
  def has_any_keys?(map, keys) do
    Enum.any?(map, fn {k, _} -> k in keys end)
  end

  @doc """
  Converts the keys of a map from strings to atoms.
  ### Example

    iex> SharedUtils.Map.keys_to_atoms(%{"foo" => "bar"})
    %{foo: "bar"}

    iex> SharedUtils.Map.keys_to_atoms(%{"foo" => "bar", "baz" => [%{"bip" => "bap"}]})
    %{baz: [%{bip: "bap"}], foo: "bar"}

    iex> SharedUtils.Map.keys_to_atoms(%{"foo" => %{"0" => %{"idx" => "first"}, "1" => %{"idx" => "second"}}})
    %{foo: [%{idx: "first"}, %{idx: "second"}]}
  """
  def keys_to_atoms(string_key_map) do
    Map.new(string_key_map, fn
      {k, %{} = v} -> convert_map_to_list({k, v})
      {k, v} when is_list(v) -> {String.to_atom(k), Enum.map(v, &keys_to_atoms(&1))}
      {k, v} -> {String.to_atom(k), v}
    end)
  end

  def convert_map_to_list({k, v}) do
    case numeric_keys?(v) do
      true -> {String.to_atom(k), v |> Map.values() |> Enum.map(&keys_to_atoms(&1))}
      false -> {String.to_atom(k), keys_to_atoms(v)}
    end
  end

  def numeric_keys?(map), do: map |> Map.keys() |> Enum.all?(&is_numeric?(&1))

  def is_numeric?(value) do
    case Float.parse(value) do
      :error -> false
      _ -> true
    end
  end

  @doc """
  Converts the keys of a map from atoms to strings.

  ### Example

    iex> SharedUtils.Map.keys_to_strings(%{foo: "bar"})
    %{"foo" => "bar"}
  """
  @spec keys_to_strings(%{required(:atom) => String.t()}) :: map
  def keys_to_strings(atom_key_map) do
    Map.new(atom_key_map, fn {k, v} -> {Atom.to_string(k), v} end)
  end
end
