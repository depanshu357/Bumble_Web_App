defmodule BumbleWebApp.Repo.Migrations.CreateNewChatsTable do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :match_id, references(:matches, on_delete: :delete_all)
      add :sender_id, references(:users, on_delete: :delete_all)
      add :message, :text

      timestamps()
    end

    create index(:chats, [:match_id])
    create index(:chats, [:sender_id])
  end
end
