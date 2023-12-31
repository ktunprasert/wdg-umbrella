defmodule WDG.Scraper do
  alias WDG.Chan
  alias WDG.Parser

  def scrape_for_wdg(post_ids, opts \\ []) do
    max_id = opts[:max_id] || 1

    Task.async_stream(
      post_ids,
      fn
        post_id ->
          IO.puts("Scraping post #{post_id}")

          with {:ok, thread} <- Chan.get_thread(post_id),
               true <- thread |> Chan.is_thread_wdg?() do
            IO.puts("Thread matched #{post_id} parsing...")
            [_op | non_op_posts] = thread |> Map.get("posts")

            non_op_posts
            |> Enum.filter(fn post -> post["no"] >= max_id end)
            |> Enum.map(fn post -> Map.put(post, "body", Parser.extract_post(post["com"])) end)
            |> Enum.filter(&is_post_valid?/1)
          else
            _ ->
              []
          end
      end,
      max_concurrency: opts[:con] || 50,
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
        "resto" => thread_no,
        "time" => time_unix
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

        params = %{
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
          updated_at: now,
          posted_at: time_unix |> DateTime.from_unix!() |> DateTime.to_naive()
        }

        WDG.Post.changeset(%WDG.Post{}, params)
        |> WDG.Repo.insert()
    end)
    |> Enum.reduce({0, 0}, fn
      {:ok, _}, {success, ignored} -> {success + 1, ignored}
      {:error, _}, {success, ignored} -> {success, ignored + 1}
      _, acc -> acc
    end)
  end

  defp is_post_valid?(%{"body" => nil}), do: nil

  defp is_post_valid?(%{"body" => body}) do
    count =
      body
      |> Map.to_list()
      |> Enum.count(fn {_, v} -> v == nil end)

    # if the nil count is less than to 5, then it's a valid post
    count < 5
  end
end
