defmodule WDG.Post do
  use Ecto.Schema

  schema "posts" do
    field(:title, :string)
    field(:dev, :string)
    field(:repo, :string)
    field(:tools, {:array, :string})
    field(:link, :string)
    field(:description, :string)
    field(:post_num, :integer)
    field(:thread_no, :integer)
    field(:image, :binary)
    field(:image_ext, :string)
    field(:posted_at, :naive_datetime)

    timestamps()
  end

  def changeset(post, params \\ %{}) do
    post
    |> Ecto.Changeset.cast(params, [
      :title,
      :dev,
      :repo,
      :tools,
      :link,
      :description,
      :post_num,
      :thread_no,
      :image,
      :image_ext,
      :posted_at
    ])
    |> Ecto.Changeset.validate_required([:title])
    |> Ecto.Changeset.unique_constraint(:post_num)
  end
end
