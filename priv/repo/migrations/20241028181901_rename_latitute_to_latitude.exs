defmodule BumbleWebApp.Repo.Migrations.RenameLatituteToLatitude do
  use Ecto.Migration

  def change do
    rename table(:users), :latitute, to: :latitude
  end
end
