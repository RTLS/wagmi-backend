defmodule SharedUtils.Support.IdHelpers do
  @moduledoc "ID helpers for tests."

  import ExUnit.Assertions, only: [assert: 1]

  def assert_id(schema_a, schema_b), do: assert(equal_ids?(schema_a, schema_b))

  def equal_ids?(schema_a, schema_b) when length(schema_a) !== length(schema_b), do: false

  def equal_ids?(schema_a, schema_b) when is_binary(schema_a) and is_binary(schema_b) do
    schema_a === schema_b
  end

  def equal_ids?(schema_a, schema_b) when is_integer(schema_a) and is_binary(schema_b) do
    schema_a === String.to_integer(schema_b)
  end

  def equal_ids?(schema_a, schema_b) when is_integer(schema_b) and is_binary(schema_a) do
    String.to_integer(schema_a) === schema_b
  end

  def equal_ids?(lesson_a, lesson_b) when is_map(lesson_a) and is_map(lesson_b) do
    get_id(lesson_a) === get_id(lesson_b)
  end

  def equal_ids?(schema_a, schema_b) when is_list(schema_a) and is_list(schema_b) do
    schema_b = sort_by_id(schema_b)

    schema_a
    |> sort_by_id
    |> Enum.with_index()
    |> Enum.all?(fn {item, i} ->
      equal_ids?(item, Enum.at(schema_b, i))
    end)
  end

  defp sort_by_id(schema), do: Enum.sort_by(schema, &get_id/1)

  defp get_id(%{"id" => id}) when is_binary(id), do: String.to_integer(id)
  defp get_id(%{id: id}) when is_integer(id), do: id
end
