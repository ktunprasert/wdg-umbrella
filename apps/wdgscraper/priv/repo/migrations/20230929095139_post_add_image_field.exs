defmodule WDG.Repo.Migrations.PostAddImageField do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :image, :binary
    end
  end
end
