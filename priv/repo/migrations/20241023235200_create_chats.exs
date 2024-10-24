defmodule BumbleWebApp.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :match_id, references(:matches, on_delete: :delete_all)
      add :user1_id, references(:users, on_delete: :delete_all)
      add :user2_id, references(:users, on_delete: :delete_all)
      add :sender_id, references(:users, on_delete: :delete_all)
      add :chat_id, :string
      add :message, :text
      add :sent_at, :naive_datetime

      timestamps()
    end

    create index(:chats, [:match_id])
    create index(:chats, [:chat_id])
  end
end
