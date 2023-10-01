defmodule Mix.Tasks.Scrape.Catalog do
  @moduledoc "Scrapes the catalog for parseable threads and posts"
  @shortdoc "Scrape the catalog"

  use Mix.Task
  import Ecto.Query

  @impl Mix.Task

  def run(_command_line_args) do
    Mix.Task.run("app.start")

    max_id =
      WDG.Repo.one(from(p in WDG.Post, select: max(p.post_num))) || 1

    {success, ignored} =
      WDG.Chan.get_catalog()
      |> Enum.flat_map(& &1["threads"])
      |> Enum.map(&Map.get(&1, "no"))
      |> WDG.Scraper.scrape_for_wdg(max_id: max_id)
      |> WDG.Scraper.insert_posts()

    Mix.Shell.IO.info("Inserted #{success} posts")
    Mix.Shell.IO.info("Ignored #{ignored} posts")
  end
end
