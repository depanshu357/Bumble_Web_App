defmodule BumbleWebApp.LikesAndMatches.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :user_id, :id
    field :liked_user_id, :id

    timestamps()
  end

  @doc false
  def like_changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :liked_user_id])
    |> validate_required([:user_id, :liked_user_id])
    |> unique_constraint([:user_id, :liked_user_id], message: "You have already liked this user.")
  end
end
