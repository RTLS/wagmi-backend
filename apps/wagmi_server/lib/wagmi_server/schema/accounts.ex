defmodule WagmiServer.Schema.Accounts do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
  end
end
