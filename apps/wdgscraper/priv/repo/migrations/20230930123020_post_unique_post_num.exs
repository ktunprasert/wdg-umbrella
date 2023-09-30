defmodule WDG.Repo.Migrations.PostUniquePostNum do
  use Ecto.Migration

  def change do
    create unique_index(:posts, [:post_num])
  end
end
