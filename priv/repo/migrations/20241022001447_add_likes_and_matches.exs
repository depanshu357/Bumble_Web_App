defmodule BumbleWebApp.Repo.Migrations.AddLikesAndMatches do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :liked_user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:likes, [:user_id, :liked_user_id])

    create table(:matches) do
      add :user1_id, references(:users, on_delete: :delete_all)
      add :user2_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:matches, [:user1_id, :user2_id])
  end
end
