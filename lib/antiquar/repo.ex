defmodule Antiquar.Repo do
  use Ecto.Repo,
    otp_app: :antiquar,
    adapter: Ecto.Adapters.Postgres
end
