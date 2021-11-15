defmodule SharedUtils.Collection do
  @moduledoc """
    Functions that useful for sorting date or
    plucking Struct/map
  """

  @doc """
  Pulls a singular key for each item in collection

  ### Example

  iex> SharedUtils.Collection.pluck([
  ...>   %SampleStruct{id: 1},
  ...>   %SampleStruct{id: 2}
  ...> ], :id)
  [1, 2]

  iex> SharedUtils.Collection.pluck([%{b: 1}, %{b: 2}, %{b: 3}], :b)
  [1, 2, 3]
  """
  @spec pluck([map], atom | String.t()) :: [any]
  def pluck(collection, prop), do: Enum.map(collection, &Map.get(&1, prop))

  @doc """
  Wraps an item into an object under a property

  ### Example

  iex> SharedUtils.Collection.wrap([1, 2, 3], :a)
  [%{a: 1}, %{a: 2}, %{a: 3}]
  """
  @spec wrap([map], atom | String.t()) :: [any]
  def wrap(collection, prop), do: Enum.map(collection, &%{prop => &1})

  @doc """
  Sorts a collection by a date

  ### Example

  iex> SharedUtils.Collection.sort_by_date([
  ...>   %SampleStruct{id: 1, created_at: DateTime.utc_now()},
  ...>   %SampleStruct{id: 2, created_at: DateTime.add(DateTime.utc_now(), 3000, :second)},
  ...>   %SampleStruct{id: 3, created_at: DateTime.add(DateTime.utc_now(), 2000, :second)}
  ...> ], :desc, &(&1.created_at)) |> Enum.map(&(&1.id))
  [2, 3, 1]

  iex> SharedUtils.Collection.sort_by_date([
  ...>   %SampleStruct{id: 1, created_at: DateTime.utc_now()},
  ...>   %SampleStruct{id: 2, created_at: DateTime.add(DateTime.utc_now(), 300, :second)},
  ...>   %SampleStruct{id: 3, created_at: DateTime.add(DateTime.utc_now(), 200, :second)}
  ...> ], :asc, &(&1.created_at)) |> Enum.map(&(&1.id))
  [1, 3, 2]
  iex> SharedUtils.Collection.sort_by_date([
  ...>   %SampleStruct{id: 1, created_at: DateTime.utc_now()},
  ...>   %SampleStruct{id: 2, created_at: DateTime.add(DateTime.utc_now(), 300, :second)},
  ...>   %SampleStruct{id: 3, created_at: DateTime.add(DateTime.utc_now(), 200, :second)}
  ...> ], :oop, &(&1.created_at)) |> Enum.map(&(&1.id))
  ** (RuntimeError) oop is not a valid way to sort
  """
  @spec sort_by_date([map], :desc | :asc, (any -> DateTime.t())) :: [map]
  def sort_by_date(enum, direction, mapper \\ & &1)

  def sort_by_date(enum, direction, mapper) when direction in [:desc, :asc] do
    Enum.sort_by(enum, mapper, fn a, b ->
      case DateTime.compare(a, b) do
        :eq -> true
        :lt when direction === :asc -> true
        :gt when direction === :asc -> false
        :lt -> false
        :gt -> true
      end
    end)
  end

  def sort_by_date(_, direction, _) do
    raise "#{direction} is not a valid way to sort"
  end

  @doc """
  Converts structs to maps deeply

  ### Example

    iex> SharedUtils.Collection.from_deep_struct(%SampleStruct{
    ...>   id: [%SampleStruct{
    ...>     id: %SampleStruct{id: :ok}
    ...>   }]
    ...> })
    %{created_at: nil, id: [%{created_at: nil, id: %{created_at: nil, id: :ok}}]}

    iex> SharedUtils.Collection.from_deep_struct(%{
    ...>   id: [%SampleStruct{id: 10}]
    ...> })
    %{id: [%{created_at: nil, id: 10}]}
  """
  @spec from_deep_struct(struct) :: map | list(map)
  def from_deep_struct(structs) when is_list(structs) do
    Enum.map(structs, &from_deep_struct/1)
  end

  def from_deep_struct(%schema{} = date_time) when schema in [NaiveDateTime, DateTime] do
    date_time
  end

  def from_deep_struct(struct) when is_struct(struct) do
    struct |> Map.from_struct() |> from_deep_struct()
  end

  def from_deep_struct(map) do
    Enum.reduce(map, map, fn
      {key, value}, acc when is_struct(value) or is_list(value) ->
        Map.put(acc, key, from_deep_struct(value))

      _value, acc ->
        acc
    end)
  end
end
