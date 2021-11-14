defmodule WagmiServer.Schema.Types.Auth do
  use Absinthe.Schema.Notation

  object :user do
    field(:id, :id)
    field(:phone_number, :string)
  end

  object :user_session do
    field(:session_token, :string)
    field(:user, :user)
  end
end
