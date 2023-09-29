defmodule Mix.Tasks.Scrape.Archive do
  @moduledoc "Scrapes the archive for WDG thread and retrieve parseable posts"
  @shortdoc "Scrape the archive"

  use Mix.Task
  import Ecto.Query

  @impl Mix.Task
  def run(_command_line_args) do
    Mix.Task.run("app.start")

    max_id =
      WDG.Repo.one(from(p in WDG.Post, select: max(p.post_num))) || 1

    ids =
      WDG.Chan.get_archive()
      |> Enum.filter(fn id -> id >= max_id end)

    {num, _} = WDG.Scraper.insert_posts(WDG.Scraper.scrape_for_wdg(ids))

    Mix.Shell.IO.info("Inserted #{num} posts")
  end
end
