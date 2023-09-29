defmodule WDG.Repo do
  use Ecto.Repo,
    otp_app: :wdgscraper,
    adapter: Ecto.Adapters.SQLite3
end
