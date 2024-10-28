defmodule BumbleWebApp.Repo.Migrations.SetDefaultValuesForGenderAndLocation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :gender, :string, default: "Male", null: false

      # Set default latitude and longitude for a location in Delhi
      modify :latitude, :float, default: 28.6139, null: false
      modify :longitude, :float, default: 77.2090, null: false
    end
  end
end
