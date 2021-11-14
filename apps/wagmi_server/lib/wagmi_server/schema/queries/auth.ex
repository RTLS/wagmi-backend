defmodule WagmiServer.Schema.Queries.Auth do
  use Absinthe.Schema.Notation

  alias WagmiServer.Resolvers

  object :auth_queries do
    @desc "Gets the current user from the session."
    field :me, :user do
      resolve(&Resolvers.Auth.me/2)
    end
  end
end
