defmodule WDG.Desu do
  @board "g"
  @root "https://desuarchive.org/_/api/chan/"
  alias HTTPoison, as: R

  alias WDG.Parser

  def search(text, board \\ @board) do
    query = URI.encode_query(text: text, board: board)

    R.get!(@root <> "search/?#{query}")
    |> Map.get(:body)
    |> Jason.decode!()
    |> get_in(["0", "posts"])
  end

  def scrape_for_parseable(posts) do
    Task.async_stream(
      posts,
      fn post ->
        IO.puts("Scraping post #{post["num"]}")

        with true <- post["comment_sanitized"] |> Parser.is_scrape_target?() do
          IO.puts("Post matched #{post["num"]} parsing...")

          body = Parser.extract_post(post["comment_sanitized"])

          if body |> Map.to_list() |> Enum.count(fn {_, v} -> v == nil end) < 5 do
            post
            |> Map.put("body", body)
          else
            post
            |> Map.put("body", nil)
          end
        else
          _ -> false
        end
      end,
      timeout: :infinity
    )
    |> Enum.reduce(
      [],
      fn
        {:ok, false}, acc -> acc
        {:ok, %{"body" => nil}} = _post, acc -> acc
        {:ok, %{} = post}, acc -> [post | acc]
        _, acc -> acc
      end
    )
    |> Enum.to_list()
  end

  def insert_posts(posts) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    posts
    |> List.flatten()
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
        "timestamp" => time_unix,
        "num" => post_num,
        "thread_num" => thread_no,
        "media" => media
      } ->
        {image, ext} =
          if media != nil do
            [ext | _rest] = String.split(media["media"], ".") |> Enum.reverse()
            {:ok, %{body: image}} = HTTPoison.get(Map.get(media, "media_link"))
            {image, ".#{ext}"}
          else
            {nil, nil}
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
          post_num: post_num |> String.to_integer(),
          thread_no: thread_no |> String.to_integer(),
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
end
