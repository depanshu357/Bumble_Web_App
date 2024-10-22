defmodule BumbleWebApp.LikesAndMatches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :user1_id, :id
    field :user2_id, :id

    timestamps()
  end

  @doc false
  def matches_changeset(match, attrs) do
    match
    |> cast(attrs, [:user1_id, :user2_id])
    |> validate_required([:user1_id, :user2_id])
    |> unique_constraint([:user1_id, :user2_id], message: "This match already exists.")
  end
end
