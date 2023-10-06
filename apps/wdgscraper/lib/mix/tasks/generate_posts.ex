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
      WDG.Repo.all(from(p in WDG.Post, order_by: [desc: p.posted_at]))

    posts
    |> Enum.each(fn post ->
      {status, image_text} = write_image(post)

      IO.puts("Wrote image #{post.post_num} with status #{inspect(status)}")

      date_prefix =
        WDG.Repo.one(from(p in WDG.Post, select: max(p.posted_at), where: p.title == ^post.title))
        |> NaiveDateTime.to_date()

      filename = File.cwd!() <> ~s(/posts/#{date_prefix}-#{slugify(post.title)}.md)

      status = write_post(post, image_text, filename)

      IO.puts("Wrote post #{post.post_num} with status #{inspect(status)}")
    end)
  end

  defp write_post(%WDG.Post{} = post, image_text \\ "", filename) do
    {tags, langs} =
      case {post.dev, post.tools} do
        {nil, nil} -> {nil, nil}
        {dev, nil} -> {dev, nil}
        {nil, tools} -> {Enum.join(tools, ", "), Enum.join(tools, ", ")}
        {dev, tools} -> {Enum.join([dev | tools], ", "), Enum.join(tools, ", ")}
      end

    {content, file} =
      if File.exists?(filename) do
        {:ok, file} = File.open(filename, [:append])
        {gen_subsequent_post(post, image_text), file}
      else
        {:ok, file} = File.open(filename, [:write])
        {gen_initial_post(post, image_text, tags, langs), file}
      end

    IO.binwrite(file, content)
    File.close(file)
    :ok
  end

  defp gen_post_header(%WDG.Post{} = post) do
    """
    <p style="display:flex; gap: 1rem">
    <a target="_blank" href="#{build_link(post.thread_no)}"> >>/wdg/#{post.thread_no} </a>
    <a target="_blank" href="#{build_link(post.thread_no, post.post_num)}"> >>#{post.post_num} </a>
    <span style="flex-grow: 1; text-align: end"> #{post.posted_at} </span>
    </p>
    """
  end

  defp gen_initial_post(%WDG.Post{} = post, image_text, tags, langs) do
    """
    ---
    title: #{post.title}
    date: #{post.posted_at}
    tags: #{tags}
    dev: #{post.dev}
    langs: #{langs}
    post: #{post.post_num}
    thread: #{post.thread_no}
    post_link: #{build_link(post.thread_no, post.post_num)}
    thread_link: #{build_link(post.thread_no)}
    link: #{post.link}
    repo: #{post.repo}
    ---

    #{gen_post_header(post)}

    #{image_text}

    #{post.description}
    <br>
    ---
    """
  end

  defp gen_subsequent_post(%WDG.Post{} = post, image_text) do
    """
    #{gen_post_header(post)}

    #{image_text}

    #{post.description}
    <br>
    ---
    """
  end

  defp slugify(string) do
    string |> String.replace(~r/[^a-zA-Z0-9]/, "-")
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
