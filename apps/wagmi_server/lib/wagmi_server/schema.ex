defmodule WagmiServer.Schema do
  use Absinthe.Schema

  alias WagmiServer.Schema.{Types, Queries, Mutations}

  import_types(Types.Auth)
  import_types(Queries.Auth)
  import_types(Mutations.Auth)

  query do
    import_fields(:auth_queries)
  end

  mutation do
    import_fields(:auth_mutations)
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [WagmiServer.Middlewares.HandleChangesetErrors]
  end

  def middleware(middleware, _field, _object), do: middleware
end
