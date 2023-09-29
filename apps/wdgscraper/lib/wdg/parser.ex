defmodule WDG.Parser do
  @title ~r/::\s?(.+)\s?::/U
  @dev ~r/dev::\s?([^<]+)<?/
  @tools ~r/tools::\s?([^<]+)<?/
  @link ~r/link::\s?([^<]+)<?/
  @repo ~r/repo::\s?([^<]+)<?/
  @progress ~r/progress::\s?([^<]+)(?:<\/pre>)?/

  def is_scrape_target?(string) do
    String.match?(string, @title)
  end

  def extract_title(string) do
    Regex.run(@title, string) |> handle_regex_run()
  end

  def extract_dev(string) do
    Regex.run(@dev, string) |> handle_regex_run()
  end

  def extract_tools(string) do
    Regex.run(@tools, string) |> handle_regex_run()
  end

  def extract_link(string) do
    Regex.run(@link, string) |> handle_regex_run()
  end

  def extract_repo(string) do
    Regex.run(@repo, string) |> handle_regex_run()
  end

  def extract_progress(string) do
    case String.match?(string, @progress) do
      false ->
        nil

      true ->
        string
        |> String.replace("<br>", "\n")
        |> then(&Regex.scan(@progress, &1))
        |> List.flatten()
        |> List.last()
        |> String.trim()
    end
  end

  def extract_post(body) do
    case is_scrape_target?(body) do
      false ->
        nil

      true ->
        body = body |> String.replace("<wbr>", "")
        %{
          title: extract_title(body),
          dev: extract_dev(body),
          tools: extract_tools(body),
          link: extract_link(body),
          repo: extract_repo(body),
          progress: extract_progress(body)
        }
    end
  end

  defp handle_regex_run(nil), do: nil
  defp handle_regex_run(match), do: match |> List.last() |> String.trim()
end
