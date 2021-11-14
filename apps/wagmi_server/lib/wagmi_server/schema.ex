defmodule WagmiServer.Schema do
  use Absinthe.Schema

  alias WagmiServer.Schema.{Types, Mutations}

  import_types Types.Auth
  import_types Mutations.Auth

  query do
    @desc "Gets the current user from the session."
    field :me, :user do
      resolve &Resolvers.Auth.me/3
    end
  end

  mutation do
    import_fields :auth_mutations
  end

  alias WagmiServer.Resolvers
end
