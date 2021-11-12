defmodule WagmiServer.Schema.User do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
  end
end
