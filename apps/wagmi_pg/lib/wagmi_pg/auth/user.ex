defmodule WagmiPG.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias WagmiPG.Helpers

  @primary_key {:id, :binary_id, [autogenerate: true]}
  schema "user" do
    field :phone_number, :string

    timestamps()
  end

  @required_params [:phone_number]
  @all_params @required_params

  def create_changeset(params), do: changeset(%User{}, params)

  def changeset(%User{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> Helpers.PhoneNumber.validate_changeset()
    |> unique_constraint(:phone_number)
  end
end
