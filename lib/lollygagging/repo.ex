defmodule Lollygagging.Repo do
  use Ecto.Repo,
    otp_app: :lollygagging,
    adapter: Ecto.Adapters.Postgres
end
