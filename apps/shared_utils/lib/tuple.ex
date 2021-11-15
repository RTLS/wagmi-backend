defmodule SharedUtils.Tuple do
  @doc """
  Simplify ok tuple

  ### Example

  iex> SharedUtils.Tuple.simplify_ok({:ok, 1})
  :ok

  iex> SharedUtils.Tuple.simplify_ok(:ok)
  :ok

  iex> SharedUtils.Tuple.simplify_ok({:error, 3})
  {:error, 3}
  """
  @spec simplify_ok({:ok, any}) :: :ok
  @spec simplify_ok({:error, term}) :: {:error, term}
  @spec simplify_ok(:ok) :: :ok
  def simplify_ok({:ok, _}), do: :ok
  def simplify_ok(x), do: x
end
