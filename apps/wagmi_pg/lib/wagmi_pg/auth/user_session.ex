defmodule WagmiPG.Auth.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  alias WagmiPG.Auth.{User, UserSession}

  schema "user_session" do
    field(:hashed_token, :string, redact: true)
    field(:session_token, :string, virtual: true)

    belongs_to(:user, User, type: :binary_id)

    timestamps(updated_at: false)
  end

  @required_params [:hashed_token, :user_id]
  @all_params [:session_token | @required_params]
  @hash_algorithm :sha256
  @token_length 32

  def create_changeset(params), do: changeset(%UserSession{}, params)

  def changeset(%UserSession{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> unique_constraint(:session_token)
  end

  def generate_user_session_params(user_id) do
    token = :crypto.strong_rand_bytes(@token_length)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    %{
      user_id: user_id,
      session_token: Base.url_encode64(token, padding: false),
      hashed_token: Base.url_encode64(hashed_token, padding: false)
    }
  end

  def decode_and_hash_token(session_token) do
    with {:ok, decoded} <- Base.url_decode64(session_token, padding: false) do
      {:ok, @hash_algorithm |> :crypto.hash(decoded) |> Base.url_encode64(padding: false)}
    end
  end
end
