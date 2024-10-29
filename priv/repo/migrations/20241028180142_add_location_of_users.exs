defmodule BumbleWebApp.Repo.Migrations.AddLocationOfUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :latitute, :float
      add :longitude, :float
    end
  end
end
