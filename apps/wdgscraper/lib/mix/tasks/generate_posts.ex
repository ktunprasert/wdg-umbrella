defmodule Mix.Tasks.Generate.Posts do
  @moduledoc "Generates posts from the db into serum consumable files"
  @shortdoc "Generate posts from the db"

  use Mix.Task
  import Ecto.Query

  @base_url "https://boards.4channel.org/g/thread/"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    posts =
      WDG.Repo.all(from(p in WDG.Post, order_by: [asc: p.post_num]))

    posts
    |> Task.async_stream(fn post ->
      {status, image_text} = write_image(post)

      IO.puts("Wrote image #{post.post_num} with status #{inspect(status)}")

      status = write_post(post, image_text)
      IO.puts("Wrote post #{post.post_num} with status #{inspect(status)}")
    end)
    |> Enum.to_list()
  end

  defp write_post(%WDG.Post{} = post, image_text \\ "") do
    tags = [post.dev | post.tools] |> Enum.join(", ")

    content = """
    ---
    title: #{post.title}
    date: #{post.posted_at}
    tags: #{tags}
    dev: #{post.dev}
    langs: #{Enum.join(post.tools, ", ")}
    post: #{post.post_num}
    thread: #{post.thread_no}
    post_link: #{build_link(post.thread_no, post.post_num)}
    thread_link: #{build_link(post.thread_no)}
    link: #{post.link}
    repo: #{post.repo}
    ---

    #{image_text}

    #{post.description}
    """

    date_prefix = post.posted_at |> NaiveDateTime.to_date()

    {:ok, file} =
      File.open(File.cwd!() <> "/posts/#{date_prefix}-#{post.post_num}.md", [:write])

    IO.binwrite(file, content)
    File.close(file)
    :ok
  end

  defp write_image(%WDG.Post{image: nil}), do: {:no_image, ""}

  defp write_image(%WDG.Post{} = post) do
    {:ok, file} =
      File.open(File.cwd!() <> "/assets/images/#{post.post_num}#{post.image_ext}", [
        :write
      ])

    IO.binwrite(file, post.image)
    File.close(file)
    {:ok, "![img](/assets/images/#{post.post_num}#{post.image_ext})"}
  end

  defp build_link(thread_no, post_no), do: @base_url <> "#{thread_no}#p#{post_no}"
  defp build_link(thread_no), do: @base_url <> "#{thread_no}"
end
