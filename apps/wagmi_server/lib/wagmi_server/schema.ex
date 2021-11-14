defmodule WagmiServer.Schema do
  use Absinthe.Schema

  alias WagmiServer.Resolvers
  alias WagmiServer.Schema.{Types, Mutations}

  import_types(Types.Auth)
  import_types(Mutations.Auth)

  query do
    @desc "Gets the current user from the session."
    field :me, :user do
      resolve(&Resolvers.Auth.me/2)
    end
  end

  mutation do
    import_fields(:auth_mutations)
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [WagmiServer.Middlewares.HandleChangesetErrors]
  end

  def middleware(middleware, _field, _object), do: middleware
end
