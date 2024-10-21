defmodule BumbleWebApp.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo_url, :string
      add :description, :text
    end
  end
end
