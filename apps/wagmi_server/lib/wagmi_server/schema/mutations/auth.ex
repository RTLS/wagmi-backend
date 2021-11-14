defmodule WagmiServer.Schema.Mutations.Auth do
  use Absinthe.Schema.Notation

  alias WagmiServer.Resolvers

  object :auth_mutations do
    field :update_user, :user do
      arg(:username, :string)

      resolve(&Resolvers.Auth.update_user/2)
    end

    field :send_security_code, :string do
      arg(:phone_number, non_null(:string))

      resolve(&Resolvers.Auth.send_security_code/2)
    end

    field :verify_security_code, :user_session do
      arg(:phone_number, non_null(:string))
      arg(:security_code, non_null(:string))

      resolve(&Resolvers.Auth.verify_security_code/2)
    end
  end
end
