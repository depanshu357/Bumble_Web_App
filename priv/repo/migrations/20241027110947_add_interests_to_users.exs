defmodule BumbleWebApp.Repo.Migrations.AddInterestsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :interests, {:array, :string}, default: []
    end
  end
end
