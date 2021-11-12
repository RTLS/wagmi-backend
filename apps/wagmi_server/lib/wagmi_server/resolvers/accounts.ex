defmodule WagmiServer.Resolvers.Accounts do
  def me(_parent, _args, _resolution) do
    {:ok, %{id: "some id"}}
  end
end
