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

    {num, _} =
      WDG.Scraper.scrape_for_wdg(ids)
      |> Enum.map(fn
        %{
          "body" => %{
            link: link,
            progress: progress,
            title: title,
            dev: dev,
            tools: tools,
            repo: repo
          },
          "no" => post_num,
          "ext" => ext,
          "tim" => filename
        } = post ->
          image =
            if Map.get(post, "filename") != nil do
              {:ok, %{body: image}} = HTTPoison.get("https://i.4cdn.org/g/#{filename}#{ext}")
              image
            else
              nil
            end

          now =
            NaiveDateTime.utc_now()
            |> NaiveDateTime.truncate(:second)

          %{
            title: title,
            dev: dev,
            repo: repo,
            tools: tools |> String.split(",") |> Enum.map(&String.trim/1),
            link: link,
            description: progress,
            post_num: post_num,
            image: image,
            image_ext: ext,
            inserted_at: now,
            updated_at: now
          }
      end)
      |> then(&WDG.Repo.insert_all(WDG.Post, &1))

      Mix.Shell.IO.info("Inserted #{num} posts")
  end
end
