defmodule WDG.Scraper do
  alias WDG.Chan
  alias WDG.Parser

  def scrape_for_wdg(post_ids, con \\ 50) do
    Task.async_stream(
      post_ids,
      fn
        post_id ->
          IO.puts("Scraping post #{post_id}")

          with thread <- Chan.get_thread(post_id),
               true <- thread |> Chan.is_thread_wdg?() do
            IO.puts("Thread matched #{post_id} parsing...")
            [_op | non_op_posts] = thread |> Map.get("posts")

            non_op_posts
            |> Enum.map(fn post -> Map.put(post, "body", Parser.extract_post(post["com"])) end)
            |> Enum.filter(fn post ->
              case post["body"] do
                nil ->
                  false

                body ->
                  count =
                    body
                    |> Map.to_list()
                    |> Enum.count(fn {_, v} -> v == nil end)

                  # if the nil count is less than to 5, then it's a valid post
                  count < 5
              end
            end)
          end
      end,
      max_concurrency: con,
      timeout: :infinity
    )
    |> Enum.reduce([], fn
      {:ok, false}, acc -> acc
      {:ok, posts}, acc -> Enum.concat(acc, posts)
    end)
  end

  def insert_posts(posts) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    posts
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
        "resto" => thread_no
      } = post ->
        {filename, ext} = {Map.get(post, "tim"), Map.get(post, "ext")}

        image =
          if Map.get(post, "filename") != nil do
            {:ok, %{body: image}} = HTTPoison.get("https://i.4cdn.org/g/#{filename}#{ext}")
            image
          else
            nil
          end

        tools =
          case tools do
            nil -> nil
            string -> string |> String.split(",") |> Enum.map(&String.trim/1)
          end

        %{
          title: title,
          dev: dev,
          repo: repo,
          tools: tools,
          link: link,
          description: progress,
          post_num: post_num,
          thread_no: thread_no,
          image: image,
          image_ext: ext,
          inserted_at: now,
          updated_at: now
        }
    end)
    |> then(&WDG.Repo.insert_all(WDG.Post, &1))
  end
end
