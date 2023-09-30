defmodule Mix.Tasks.Scrape.Desu do
  @moduledoc "Scrapes the desuarchive parseable posts"
  @shortdoc "Scrape the desuarchive"

  use Mix.Task
  alias WDG.Desu

  @impl Mix.Task
  def run(_command_line_args) do
    Mix.Task.run("app.start")

    {:ok, json} = File.read(File.cwd!() <> "/desu.json")
    search_terms = json |> String.replace("\n", "") |> Jason.decode!()

    {success, ignored} =
      search_terms
      |> Task.async_stream(
        fn term ->
          term |> Desu.search() |> Desu.scrape_for_parseable() |> Desu.insert_posts()
        end,
        timeout: :infinity
      )
      |> Enum.reduce({0, 0}, fn {:ok, {success, errors}}, {n1, n2} ->
        {n1 + success, n2 + errors}
      end)

    Mix.Shell.IO.info("Inserted #{success} posts")
    Mix.Shell.IO.info("Ignored #{ignored} posts")
  end
end
