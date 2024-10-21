defmodule BumbleWebApp.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do

      timestamps(type: :utc_datetime)
    end
  end
end
