defmodule WagmiServer.Plugs.Auth do
  @behaviour Plug

  import Plug.Conn

  alias WagmiPG.Auth
  alias WagmiPG.Auth.{User, UserSession}

  @max_session_age :timer.hours(24) * 90

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      res ->
        %{}
    end
  end

  defp authorize(token) do
    with {:ok, hashed_token} <- Auth.UserSession.decode_and_hash_token(token),
         {:ok, %UserSession{user: %User{} = user}} <-
           Auth.find_user_session(%{
             hashed_token: hashed_token,
             inserted_at: %{gt: DateTime.add(DateTime.utc_now(), -@max_session_age, :millisecond)},
             preload: :user
           }) do
      {:ok, user}
    end
  end
end
