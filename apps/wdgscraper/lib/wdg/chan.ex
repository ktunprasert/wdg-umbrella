defmodule WDG.Chan do
  @board "g"
  @root "https://a.4cdn.org/"

  alias HTTPoison, as: R

  def get_archive(board \\ @board) do
    R.get!(@root <> board <> "/archive.json")
    |> Map.get(:body)
    |> Jason.decode!()
  end

  def get_thread(post_id, board \\ @board) do
    R.get!(@root <> "#{board}/thread/#{post_id}.json")
    |> Map.get(:body)
    |> Jason.decode!()
  end

  def is_thread_wdg?(%{"posts" => [post | _]}) do
    is_wdg?(post["sub"])
  end

  def is_wdg?(subject) when is_binary(subject) do
    String.match?(subject, ~r/\/wdg\//)
  end

  def is_wdg?(_), do: false
end
