defmodule WagmiServer.Resolvers.User do
  def all_users(_parent, _args, _resolution) do
    {:ok, [%{id: "some id"}]}
  end
end
