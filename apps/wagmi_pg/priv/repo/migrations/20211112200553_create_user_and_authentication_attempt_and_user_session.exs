defmodule WagmiPG.Repo.Migrations.CreateUserAndAuthenticationAttemptAndUserSession do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phone_number, :text, null: false

      timestamps()
    end

    create unique_index(:user, :phone_number)

    create table(:authentication_attempt) do
      add :phone_number, :text, null: false
      add :security_code, :text, null: false
      add :attempts, :smallint, null: false, default: 0
      add :expires_at, :utc_datetime, null: false
    end

    create unique_index(:authentication_attempt, :phone_number)

    create table(:user_session, primary_key: false) do
      add :session_token, :text, primary_key: true
      add :user_id, references(:user, type: :binary_id), null: false
      add :expires_at, :utc_datetime, null: false

      timestamps(updated_at: false)
    end
  end
end
