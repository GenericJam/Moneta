defmodule Moneta.Repo do
  use Ecto.Repo,
    otp_app: :moneta,
    adapter: Ecto.Adapters.Postgres
end
