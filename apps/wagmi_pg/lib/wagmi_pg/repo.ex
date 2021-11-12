defmodule WagmiPG.Repo do
  use Ecto.Repo,
    otp_app: :wagmi_pg,
    adapter: Ecto.Adapters.Postgres
end
