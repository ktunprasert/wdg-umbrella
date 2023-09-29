defmodule WDG.Repo do
  use Ecto.Repo,
    otp_app: :wdg,
    adapter: Ecto.Adapters.SQLite3
end
