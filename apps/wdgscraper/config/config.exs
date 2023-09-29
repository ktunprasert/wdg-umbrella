import Config

config :wdgscraper, WDG.Repo,
  database: Path.expand("../../db/scraper.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :wdgscraper, ecto_repos: [WDG.Repo]
