defmodule BumbleWebApp.Repo do
  use Ecto.Repo,
    otp_app: :bumble_web_app,
    adapter: Ecto.Adapters.Postgres
end
