defmodule SharedUtils.ConfigEnforcer do
  @moduledoc """
  This module takes in a struct that represents a configs options and
  validates it. To enforce certain keys being present we can use `@enforce_keys`

  A typical config struct can look like this

  ## Example

    ```elixir
    defmodule EnforcedConfig do
      @enforce_keys [:a]
      defstruct [:a, b: 10]
    end
    ```
  """

  @spec validate!(map, module) :: map
  @spec validate!(keyword, module) :: keyword
  @doc """
  We can validate a config map by passing the struct like
  the `EnforcedConfig` defined at the top. You can then do the following:

  ## Example

  iex> SharedUtils.ConfigEnforcer.validate!(%{a: 1}, EnforcedConfig)
  %{a: 1, b: 10}

  iex> SharedUtils.ConfigEnforcer.validate!(%{b: 20}, EnforcedConfig)
  ** (ArgumentError) the following keys must also be given when building struct \
  SharedUtils.ConfigEnforcerTest.EnforcedConfig: [:a]

  iex> SharedUtils.ConfigEnforcer.validate!([a: 1, c: 20], EnforcedConfig)
  ** (KeyError) key :c not found in: \
  %SharedUtils.ConfigEnforcerTest.EnforcedConfig{a: 1, b: 10}
  """
  def validate!(config, config_struct) when is_map(config) do
    config_struct
    |> struct!(config)
    |> Map.from_struct()
  end

  def validate!(opts, config_struct) when is_list(opts) do
    config_struct
    |> struct!(opts)
    |> Map.from_struct()
    |> Map.to_list()
  end
end
