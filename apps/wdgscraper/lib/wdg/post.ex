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
    field(:image, :binary)
    field(:image_ext, :string)

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
      :image,
      :image_ext
    ])
    |> Ecto.Changeset.validate_required([:title])
    |> Ecto.Changeset.unique_constraint(:post_num)
  end
end
