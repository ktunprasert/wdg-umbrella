defmodule Mix.Tasks.Scrape.Thread do
  @moduledoc "Scrapes the given thread IDs for valid wdg posts"
  @shortdoc "Scrape the thread for valid posts"

  use Mix.Task

  @impl Mix.Task
  def run(command_line_args) do
    Mix.Task.run("app.start")

    ids =
      command_line_args
      |> Enum.map(&String.to_integer/1)

    {success, ignored} = WDG.Scraper.insert_posts(WDG.Scraper.scrape_for_wdg(ids))

    Mix.Shell.IO.info("Inserted #{success} posts")
    Mix.Shell.IO.info("Ignored #{ignored} posts")
  end
end
