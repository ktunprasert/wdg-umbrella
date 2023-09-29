defmodule WDG.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :dev, :string
      add :repo, :string
      add :tools, {:array, :string}
      add :link, :string
      add :description, :text
      add :post_num, :integer

      timestamps()
    end
  end
end
