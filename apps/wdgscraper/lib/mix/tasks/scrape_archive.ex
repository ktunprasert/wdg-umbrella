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

    {success, ignored} =
      WDG.Chan.get_archive()
      |> WDG.Scraper.scrape_for_wdg(max_id: max_id)
      |> WDG.Scraper.insert_posts()

    Mix.Shell.IO.info("Inserted #{success} posts")
    Mix.Shell.IO.info("Ignored #{ignored} posts")
  end
end
