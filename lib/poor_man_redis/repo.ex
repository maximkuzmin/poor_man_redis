defmodule PoorManRedis.Repo do
  use Ecto.Repo,
    otp_app: :poor_man_redis,
    adapter: Ecto.Adapters.Postgres
end
