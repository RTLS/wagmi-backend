defmodule WagmiServer.Router do
  use WagmiServer, :router

  pipeline :graphql do
    plug :accepts, ["json"]
    plug WagmiServer.Plugs.Auth
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: WagmiServer.Schema
  end

  scope "/graphiql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug.GraphiQL, schema: WagmiServer.Schema
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
