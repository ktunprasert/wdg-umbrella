defmodule WDG.Repo.Migrations.PostAddThreadNo do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :thread_no, :integer
    end
  end
end
