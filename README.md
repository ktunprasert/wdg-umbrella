# WDG Umbrella Project

[![Elixir CI](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/elixir.yml/badge.svg)](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/elixir.yml)

This repo contains the source code for the scraper to scrape posts matching the specified format in the site.
The scraper will pick up these post, convert to an entity within the SQLite DB under the `apps/wdgscraper` projec.
The SQLite files are available and saved on `./db/` folder.

## Getting started

You will need Elixir installed for this project to work - assuming you have done that already here are the step-by-step guide on how to run the repository from scratch.

```bash
git clone https://github.com/ktunprasert/wdg-umbrella/
cd wdg-umbrella
# download & build the dependencies
mix deps.get
# perform migration to ensure we're on the latest
mix ecto.migrate
# launch the scraper and scrape threads for /wdg/ threads
mix scrape.acrhive
# alternatively you may use thread-based scraping
# the command below will scrape threads = [123, 456, 789]
mix scrape.thread 123 456 789
```

To genereate the static pages you will have to move into the `apps/serum_static` directory

```bash
cd apps/serum_static
# runs the local live-reload server - defaults at localhost:8080
mix serum.server
# builds the final payload for static server
MIX_ENV=prod serum.build
```

The final output are located at `apps/serum_static/site/`
