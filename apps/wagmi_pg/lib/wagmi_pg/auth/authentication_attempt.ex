defmodule WagmiPG.Auth.AuthenticationAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias WagmiPG.Helpers

  schema "authentication_attempt" do
    field :phone_number, :string
    field :security_code, :string
    field :attempts, :integer
    field :expires_at, :utc_datetime

    timestamps()
  end

  @required_params [:phone_number, :security_code, :expires_at]
  @all_params @required_params

  def create_changeset(params), do: changeset(%AuthenticationAttempt{}, params)

  def changeset(%AuthenticationAttempt{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> Helpers.PhoneNumber.validate_changeset()
    |> unique_constraint(:phone_number)
  end
end
