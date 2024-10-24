defmodule BumbleWebApp.Repo.Migrations.DropOldChatsTable do
  use Ecto.Migration

  def change do
    drop table(:chats)
  end
end
