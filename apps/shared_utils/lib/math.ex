defmodule SharedUtils.Math do
  @type num :: float | integer

  @doc """
  Given a numerator and a denominator, hands back a percentage as a float and is
  safe from division by zero's.

  ## Examples

      iex> SharedUtils.Math.percentage(1, 2)
      50.0

      iex> SharedUtils.Math.percentage(1, 0)
      1.0

      iex> SharedUtils.Math.percentage(1.0, 0.0)
      1.0
  """
  @spec percentage(num, num) :: float
  def percentage(_numerator, 0), do: 1.0
  def percentage(_numerator, 0.0), do: 1.0
  def percentage(numerator, denominator), do: numerator / denominator * 100.0
end
