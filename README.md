# WDG Umbrella Project

[![Unit Tests](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/elixir.yml/badge.svg)](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/elixir.yml)
[![Scrape and Commit](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/scrape.yml/badge.svg)](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/scrape.yml)
[![Deploy to Github.io](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/build_deploy_static.yml/badge.svg)](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/build_deploy_static.yml)

This repo contains the source code for the scraper to scrape posts matching the specified format in the site.
The scraper will pick up these post, convert to an entity within the SQLite DB under the `apps/wdgscraper` project.
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
mix scrape.archive
# this instead scrapes the catalog.json
mix scrape.catalog
# alternatively you may use thread-based scraping
# the command below will scrape threads = [123, 456, 789]
mix scrape.thread 123 456 789
```

To generate the static pages you will have to move into the `apps/serum_static` directory

```bash
cd apps/serum_static
# runs the local live-reload server - defaults at localhost:8080
mix serum.server
# builds the final payload for static server
MIX_ENV=prod serum.build
```

The final output are located at `apps/serum_static/site/`

## Pipelines

The pipeline is set up with a hourly/4 crontab meaning it runs every 4 hours, the scraper (currently `scrape.catalog`) will
pick up all the /wdg/ threads and tries to parse all the candidates to be inserted into the database.

If no posts are found or the post in that thread already exists within the database, it will be ignored.
The workflow history can be seen here [https://github.com/ktunprasert/wdg-umbrella/actions/workflows/scrape.yml](https://github.com/ktunprasert/wdg-umbrella/actions/workflows/scrape.yml)

The static site generation workflow will detect for changes within the db folder (scraper has committed something or manual removal of posts)
as well as the template changes within the `apps/serum_static/` folder as this will affect how the site will look in the end. This job
generates a production static generation payload as your basic HTML/CSS/JS and send it to the [wdg-one](https://github.com/wdg-one/) organisation's GitHub.io page.

## Post format

By default, the post format should match the following. Failure to provide a tag prefix will fail
and won't be picked up by the scraper correctly.

```
:: my-project-title ::
dev:: anon
tools:: node, react, etc
link:: https://my.website.com
repo:: https://github.com/user/repo
progress:: Lorem ipsum dolor sit amet, consetetur sadipscing elitr
```

Here's the matching regex for the enthusiast out there

```elixir
@title ~r/::\s?(.+)\s?::/U
@dev ~r/dev::\s?([^<\n]+)<?/
@tools ~r/tools::\s?([^<\n]+)<?/
@link ~r/link::\s?([^<\n]+)<?/
@repo ~r/repo::\s?([^<\n]+)<?/
@progress ~r/progress::\s?([^<]+)(?:<\/pre>)?/
```

Note that you _will_ need to provide a project title or it won't be count as a valid scrapable post
