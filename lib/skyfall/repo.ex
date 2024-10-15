defmodule Skyfall.Repo do
  use Ecto.Repo,
    otp_app: :skyfall,
    adapter: Ecto.Adapters.Postgres
end
