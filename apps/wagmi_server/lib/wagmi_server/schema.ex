defmodule WagmiServer.Schema do
  use Absinthe.Schema
  import_types WagmiServer.Schema.User

  alias WagmiServer.Resolvers

  query do
    @desc "Get all users"
    field :users, list_of(:user) do
      resolve &Resolvers.User.all_users/3
    end
  end
end

