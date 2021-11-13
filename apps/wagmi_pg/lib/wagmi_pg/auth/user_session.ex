defmodule WagmiPG.Auth.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  alias WagmiPG.Auth.{User, UserSession}

  @primary_key false
  schema "user_session" do
    field :session_token, :string
    field :expires_at, :utc_datetime

    belongs_to :user, User

    timestamps(updated_at: false)
  end

  @required_params [:session_token, :expires_at, :user_id]
  @all_params @required_params

  def create_changeset(params), do: changeset(%UserSession{}, params)

  def changeset(%UserSession{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> unique_constraint(:session_token)
  end
end
