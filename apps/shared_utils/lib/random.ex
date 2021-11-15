defmodule SharedUtils.Random do
  @moduledoc """
  Utilities for randomization
  """

  @doc """
  Passes if a random number from 1 to 100 is
  less than or equal to the percent argument.

  More likely to be true with a high percent argument.
  """
  @spec percent_to_pass?(pos_integer()) :: boolean()
  def percent_to_pass?(percent), do: :rand.uniform(100) <= percent
end
