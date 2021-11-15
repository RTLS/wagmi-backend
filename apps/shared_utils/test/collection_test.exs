defmodule SharedUtils.CollectionTest do
  use ExUnit.Case, async: true

  defmodule SampleStruct do
    defstruct [:id, :created_at]
  end

  defmodule TestStruct do
    defstruct [:a]
  end

  doctest SharedUtils.Collection
end
