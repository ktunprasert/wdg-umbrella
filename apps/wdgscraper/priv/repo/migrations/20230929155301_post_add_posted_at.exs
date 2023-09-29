defmodule WDG.Repo.Migrations.PostAddPostedAt do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:posted_at, :naive_datetime)
    end
  end
end
