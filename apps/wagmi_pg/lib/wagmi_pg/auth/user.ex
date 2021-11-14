defmodule WagmiPG.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias WagmiPG.Helpers

  @primary_key {:id, :binary_id, [autogenerate: true]}
  schema "user" do
    field :phone_number, :string
    field :username, :string

    timestamps()
  end

  @required_params [:phone_number]
  @all_params [:username | @required_params]
  @max_username_length 16

  def create_changeset(params), do: changeset(%User{}, params)

  def changeset(%User{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> validate_length(:username, max: @max_username_length)
    |> Helpers.PhoneNumber.validate_changeset()
    |> unique_constraint(:phone_number)
    |> unique_constraint(:username)
  end
end
