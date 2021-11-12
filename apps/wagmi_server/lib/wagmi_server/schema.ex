defmodule WagmiServer.Schema do
  use Absinthe.Schema
  import_types WagmiServer.Schema.Accounts

  alias WagmiServer.Resolvers

  query do
    @desc "Get all users"
    field :me, :user do
      resolve &Resolvers.Accounts.me/3
    end
  end
end

