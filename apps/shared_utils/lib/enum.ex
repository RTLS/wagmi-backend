defmodule SharedUtils.Enum do
  @moduledoc """
  Enum utils
  Do not alias this module
  as it will mess with existing Enum functions
  """
  @type status_tuple :: {:ok, any} | {:error, any}
  @type list_status_tuple :: {:ok, list(any)} | {:error, list(any)}
  @doc """
  Converts a list of status tuples `({:ok, any} | {:error, any})` into a singular
  status tuple with all errors or results in an array

  ### Example

    iex> SharedUtils.Enum.reduce_status_tuples([{:ok, 1}, {:ok, 2}, {:ok, 3}])
    {:ok, [1, 2, 3]}
    iex> SharedUtils.Enum.reduce_status_tuples([{:error, 1}, {:ok, 2}, {:error, 3}])
    {:error, [1, 3]}
    iex> SharedUtils.Enum.reduce_status_tuples([{:error, 1}, {:ok, 2}, {:ok, 3}])
    {:error, [1]}
  """
  @spec reduce_status_tuples(%Stream{:done => nil} | list(status_tuple)) :: list_status_tuple
  def reduce_status_tuples(status_tuples) do
    {status, res} =
      Enum.reduce(status_tuples, {:ok, []}, fn
        {:ok, _}, {:error, _} = e -> e
        {:ok, record}, {:ok, acc} -> {:ok, [record | acc]}
        {:error, error}, {:ok, _} -> {:error, [error]}
        {:error, e}, {:error, error_acc} -> {:error, [e | error_acc]}
      end)

    {status, Enum.reverse(res)}
  end

  @doc """
  Converts a list of status tuples from a task `({:ok, any} | {:error, any})` into a singular
  status tuple with all errors or results in an array

  ### Example
  iex> SharedUtils.Enum.reduce_task_status_tuples([{:ok, {:ok, 1}}, {:ok, {:ok, 2}}])
  {:ok, [1, 2]}
  iex> SharedUtils.Enum.reduce_task_status_tuples([{:ok, {:error, 1}}, {:ok, {:ok, 2}}, {:ok, {:error, 3}}])
  {:error, [1, 3]}
  iex> SharedUtils.Enum.reduce_task_status_tuples([{:exit, :badarith}, {:ok, {:ok, 2}}, {:ok, {:error, 3}}])
  {:error, [:badarith, 3]}
  """
  @spec reduce_task_status_tuples(Enumerable.t()) :: status_tuple
  def reduce_task_status_tuples(status_tuples) do
    {status, res} =
      Enum.reduce(status_tuples, {:ok, []}, fn
        {:ok, {:ok, _}}, {:error, _} = e -> e
        {:ok, {:ok, record}}, {:ok, acc} -> {:ok, [record | acc]}
        {:ok, {:error, error}}, {:ok, _} -> {:error, [error]}
        {:ok, {:error, e}}, {:error, error_acc} -> {:error, [e | error_acc]}
        {:exit, reason}, {:ok, _} -> {:error, [reason]}
        {:exit, reason}, {:error, error_acc} -> {:error, [reason | error_acc]}
      end)

    {status, Enum.reverse(res)}
  end

  @doc """
  Converts all string keys to string

  ### Example

    iex> SharedUtils.Enum.stringify_keys(%{"test" => 5, hello: 4})
    %{"test" => 5, "hello" => 4}
    iex> SharedUtils.Enum.stringify_keys([%{"a" => 5}, %{b: 2}])
    [%{"a" => 5}, %{"b" => 2}]
  """
  @spec stringify_keys(Enum.t()) :: Enum.t()
  def stringify_keys(map) do
    transform_keys(map, fn
      key when is_binary(key) -> key
      key when is_atom(key) -> Atom.to_string(key)
    end)
  end

  @doc """
  Converts all string keys to atoms

  ### Example

    iex> SharedUtils.Enum.atomize_keys(%{"test" => 5, hello: 4})
    %{test: 5, hello: 4}
    iex> SharedUtils.Enum.atomize_keys([%{"a" => 5}, %{b: 2}])
    [%{a: 5}, %{b: 2}]
  """
  @spec atomize_keys(Enum.t()) :: Enum.t()
  def atomize_keys(map) do
    transform_keys(map, fn
      key when is_binary(key) -> String.to_atom(key)
      key -> key
    end)
  end

  defp transform_keys(map, transform_fn) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} ->
      {transform_fn.(key), transform_keys(value, transform_fn)}
    end)
  end

  defp transform_keys(list, transform_fn) when is_list(list) do
    Enum.map(list, &transform_keys(&1, transform_fn))
  end

  defp transform_keys(item, _transform_fn), do: item

  @doc """
  Converts all string keys to string

  ### Example

    iex> SharedUtils.Enum.difference([:a, :b, :c, :e], [:e, :b, :d, :f])
    [:a, :c]
  """
  @spec difference(Enum.t(), Enum.t()) :: Enum.t()
  def difference(a, b) do
    a
    |> MapSet.new()
    |> MapSet.difference(MapSet.new(b))
    |> MapSet.to_list()
  end

  @doc """
  Returns false for empty enums, otherwise true.

  ### Example
  iex> SharedUtils.Enum.is_not_empty?([])
  false

  iex> SharedUtils.Enum.is_not_empty?([1, 2, 3])
  true
  """
  @spec is_not_empty?(map() | list()) :: boolean
  def is_not_empty?(enumerable) do
    enumerable
    |> Enum.empty?()
    |> Kernel.not()
  end

  @doc """
  Filters out all nil values

  ### Example

    iex> SharedUtils.Enum.reject_empty_values([1, %{}, nil, [], 2, 3])
    [1, 2, 3]
    iex> SharedUtils.Enum.reject_empty_values([a: 1, b: %{}, c: 3, d: [], e: nil])
    [a: 1, c: 3]
    iex> SharedUtils.Enum.reject_empty_values(%{a: 1, b: [], c: 3, d: nil, e: %{}})
    %{a: 1, c: 3}
  """

  @spec reject_empty_values(map() | list()) :: map() | list()
  def reject_empty_values(map) when is_map(map) do
    map
    |> Map.to_list()
    |> reject_empty_values
    |> Map.new()
  end

  def reject_empty_values(list) when is_list(list) do
    Enum.reject(list, fn
      {_k, nil} -> true
      {_k, []} -> true
      {_k, v} when v === %{} -> true
      [] -> true
      v when v === %{} -> true
      v -> is_nil(v)
    end)
  end

  @doc """
  Filters out all nil values

  ### Example

    iex> SharedUtils.Enum.reject_nil_values([1, nil, 2, 3])
    [1, 2, 3]
    iex> SharedUtils.Enum.reject_nil_values([a: 1, b: nil, c: 3])
    [a: 1, c: 3]
    iex> SharedUtils.Enum.reject_nil_values(%{a: 1, b: nil, c: 3})
    %{a: 1, c: 3}
  """

  @spec reject_nil_values(map() | list()) :: map() | list()

  def reject_nil_values(map) when is_map(map) do
    map
    |> Map.to_list()
    |> reject_nil_values
    |> Map.new()
  end

  def reject_nil_values(list) when is_list(list) do
    Enum.reject(list, fn
      {_k, v} -> is_nil(v)
      v -> is_nil(v)
    end)
  end

  @doc """
  Filters out all nil values

  ### Example

  iex> SharedUtils.Enum.deep_reject_nil_values([
  ...>   1,
  ...>   nil,
  ...>   %{value: nil, deep: %{key: nil}, item: 1}
  ...> ])
  [1, %{item: 1, deep: %{}}]
  """

  @spec deep_reject_nil_values(map() | list()) :: map() | list()
  def deep_reject_nil_values(list) when is_list(list) do
    list
    |> Enum.reduce([], fn
      nil, acc -> acc
      value, acc when is_map(value) or is_list(value) -> [deep_reject_nil_values(value) | acc]
      value, acc -> [value | acc]
    end)
    |> Enum.reverse()
  end

  def deep_reject_nil_values(map) when is_map(map) do
    Enum.reduce(map, map, fn
      {key, value}, acc when is_map(value) or is_list(value) ->
        Map.put(acc, key, deep_reject_nil_values(value))

      {key, nil}, acc ->
        Map.delete(acc, key)

      _value, acc ->
        acc
    end)
  end

  @doc """
  Group by but a singular value

  ### Example

  iex> SharedUtils.Enum.singular_group_by(
  ...>   [%{id: 1, prop: 2}, %{id: 2, prop: 3}],
  ...>   &(&1.id),
  ...>   &(&1.prop)
  ...> )
  %{1 => 2, 2 => 3}
  """
  @spec singular_group_by(Enum.t(), (term -> term)) :: Enum.t()
  @spec singular_group_by(Enum.t(), (term -> term), (term -> term)) :: Enum.t()
  def singular_group_by(enum, key_fn, value_fn \\ & &1) do
    enum
    |> Enum.group_by(key_fn, value_fn)
    |> Enum.into(%{}, fn {k, v} -> {k, List.first(v)} end)
  end

  @doc """
  Group by but a singular value

  ### Example

  iex> SharedUtils.Enum.ensure_map([a: 1, b: 2, c: 3])
  %{a: 1, b: 2, c: 3}

  iex> SharedUtils.Enum.ensure_map(%{a: 1, b: 2, c: 3})
  %{a: 1, b: 2, c: 3}
  """
  @spec ensure_map(Enum.t()) :: map()
  def ensure_map(list) when is_list(list), do: Map.new(list)
  def ensure_map(map), do: map

  @doc """
  Returns the intersection of two lists

  ### Example

  iex> SharedUtils.Enum.intersection([1, 2, 3], [1, 2])
  [1, 2]

  iex> SharedUtils.Enum.intersection([1, 2, 3], [4])
  []
  """
  @spec intersection(Enum.t(), Enum.t()) :: Enum.t()
  def intersection(a, b) do
    a
    |> MapSet.new()
    |> MapSet.intersection(MapSet.new(b))
    |> Enum.to_list()
  end

  @doc """
  run map over values of a keyword or map

  ### Example

  iex> SharedUtils.Enum.map_values(%{a: 1, b: 2, c: 3}, &(&1 * 2))
  %{a: 2, b: 4, c: 6}

  iex> SharedUtils.Enum.map_values([a: 1, b: 2, c: 3], &(&1 * 2))
  [a: 2, b: 4, c: 6]

  """
  @spec map_values(Enum.t(), (term -> term)) :: Enum.t()
  def map_values(enum, fnc) do
    value =
      Enum.map(enum, fn {key, value} ->
        {key, fnc.(value)}
      end)

    if is_map(enum), do: Map.new(value), else: value
  end

  @doc """
  returns average of list of numeric values

  ### Example

  iex> SharedUtils.Enum.average([])
  nil

  iex> SharedUtils.Enum.average([2])
  2.0

  iex> SharedUtils.Enum.average([2, 3])
  2.5

  """
  @spec average(list()) :: float() | nil

  def average([]), do: nil

  def average(values) do
    values
    |> Enum.sum()
    |> Kernel./(length(values))
  end

  @doc """
  returns the mode of list of values

  ### Example

  iex> SharedUtils.Enum.mode([1,1,2,3])
  [1]

  iex> SharedUtils.Enum.mode([1,3,1,2,2])
  [1, 2]

  iex> SharedUtils.Enum.mode([])
  []
  """
  @spec mode(list()) :: list()

  def mode([]), do: []

  def mode(list) do
    gb = Enum.group_by(list, & &1)
    max = Enum.map(gb, fn {_, val} -> length(val) end) |> Enum.max()
    for {key, val} <- gb, length(val) === max, do: key
  end

  @doc """
  nils out certain keys

  ### Example

  iex> SharedUtils.Enum.nilify_keys([], [])
  []

  iex> SharedUtils.Enum.nilify_keys([test: 1, tell: 3, thing: 4], [:test, :tell])
  [test: nil, tell: nil, thing: 4]

  iex> SharedUtils.Enum.nilify_keys(%{test: 1, tell: 3, thing: 4}, [:test, :tell])
  %{test: nil, tell: nil, thing: 4}

  """
  @spec nilify_keys(Enum.t(), list(atom | String.t())) :: Enum.t()

  def nilify_keys(values, keys) when is_list(values) do
    if Keyword.keyword?(values) do
      nilify_enum_keys(Keyword, values, keys)
    else
      Enum.map(values, &nilify_keys(&1, keys))
    end
  end

  def nilify_keys(value, keys) when is_map(value) do
    nilify_enum_keys(Map, value, keys)
  end

  defp nilify_enum_keys(enum_type_module, value, keys) do
    Enum.reduce(keys, value, fn key, acc_value ->
      new_val =
        if not apply(enum_type_module, :has_key?, [value, key]) do
          apply(enum_type_module, :get, [value, key])
        end

      apply(enum_type_module, :update!, [acc_value, key, fn _ -> new_val end])
    end)
  end

  @doc """
  Concats unique items

  ### Example

  iex> SharedUtils.Enum.concat_uniq_by([1, 2], [2, 3, 4], &(&1))
  [1, 2, 3, 4]

  """
  @spec concat_uniq_by(Enum.t(), Enum.t(), (any -> any)) :: Enum.t()
  def concat_uniq_by(enum_a, enum_b, mapper) do
    enum_a
    |> Stream.concat(enum_b)
    |> Enum.uniq_by(mapper)
  end
end
