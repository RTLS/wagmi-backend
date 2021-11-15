defmodule SharedUtils.Number do
  @doc """
  Restricts a number to be within a range

  ### Example

    iex> SharedUtils.Number.clamp(5, 1, 10)
    5

    iex> SharedUtils.Number.clamp(0, 1, 10)
    1

    iex> SharedUtils.Number.clamp(11, 1, 10)
    10
  """
  @spec clamp(number, number, number) :: number
  def clamp(number, minimum, _maximum) when number < minimum, do: minimum
  def clamp(number, _minimum, maximum) when number > maximum, do: maximum
  def clamp(number, _minimum, _maximum), do: number

  @doc """
  Converts boolean value to integer 1 or 0.

  ### Example

    iex> SharedUtils.Number.from_bool(true)
    1

    iex> SharedUtils.Number.from_bool(false)
    0
  """
  @spec from_bool(boolean()) :: number
  def from_bool(bool) do
    if bool, do: 1, else: 0
  end
end
