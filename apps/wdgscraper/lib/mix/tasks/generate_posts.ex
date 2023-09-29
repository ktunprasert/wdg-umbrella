defmodule Mix.Tasks.Generate.Posts do
  @moduledoc "Generates posts from the db into serum consumable files"
  @shortdoc "Generate posts from the db"

  use Mix.Task
  import Ecto.Query

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    posts =
      WDG.Repo.all(from(p in WDG.Post, order_by: [asc: p.post_num]))

    posts
    |> Task.async_stream(fn post ->
      status = write_image(post)
      IO.puts("Wrote image #{post.post_num} with status #{inspect(status)}")

      status = write_post(post)
      IO.puts("Wrote post #{post.post_num} with status #{inspect(status)}")
    end)
    |> Enum.to_list()
  end

  defp write_post(%WDG.Post{} = post) do
    tags = [post.dev | post.tools] |> Enum.join(", ")

    content = """
    ---
    title: #{post.title}
    date: #{post.inserted_at}
    tags: #{tags}
    dev: #{post.dev}
    langs: #{Enum.join(post.tools, ", ")}
    post: #{post.post_num}
    ---

    >>>#{post.post_num}

    ![img](/assets/images/#{post.post_num}#{post.image_ext})

    #{post.description}
    """

    date_prefix = post.inserted_at |> NaiveDateTime.to_date()

    {:ok, file} = File.open(File.cwd!() <> "/posts/#{date_prefix}-#{post.post_num}.md", [:write])
    IO.binwrite(file, content)
    File.close(file)
    :ok
  end

  defp write_image(%WDG.Post{image: nil}), do: :no_image

  defp write_image(%WDG.Post{} = post) do
    {:ok, file} =
      File.open(File.cwd!() <> "/assets/images/#{post.post_num}#{post.image_ext}", [:write])

    IO.binwrite(file, post.image)
    File.close(file)
    :ok
  end
end
