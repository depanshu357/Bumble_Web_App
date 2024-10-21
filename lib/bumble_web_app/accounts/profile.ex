defmodule BumbleWebApp.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [])
    |> validate_required([])
  end
end
