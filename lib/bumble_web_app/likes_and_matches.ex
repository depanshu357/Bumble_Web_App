defmodule BumbleWebApp.LikesAndMatches do
  # use BumbleWebAppWeb, :live_view

  import Ecto.Query, warn: false
  # import Ecto.Query, only: [from: 2, where: 3, left_join: 3]
  alias BumbleWebApp.Repo
  # alias BumbleWebApp.LikesAndMatches.Like
  # alias BumbleWebApp.LikesAndMatches.Match
  alias BumbleWebApp.Accounts.User
  alias BumbleWebApp.LikesAndMatches.Like
  alias BumbleWebApp.LikesAndMatches.Match


  def like_user(user_id, liked_user_id) do
    %Like{}
    |> Like.like_changeset(%{user_id: user_id, liked_user_id: liked_user_id})
    |> Repo.insert()
  end

  def check_for_match(user_id, liked_user_id) do
    # Check if the liked user has also liked the current user
    case Repo.get_by(Like, user_id: liked_user_id, liked_user_id: user_id) do
      nil -> {:ok, :no_match}
      _ ->
        # Create a match if both users liked each other
        Repo.insert(%Match{user1_id: user_id, user2_id: liked_user_id})
        {:ok, :match}
    end
  end

  def list_of_profiles(user_id) do
    # query = from(u in User,
    #              where: u.id != ^user_id,
    #              select: u)
    # Repo.all(query)
    # query = from(u in User,
    #   where: u.id != ^user_id and not exists(
    #     from(l in Like, where: l.user_id == ^user_id and l.liked_user_id == ^u.id)
    #   )
    # )
    User
    |> where([u], u.id != ^user_id)  # Exclude the current user
    |> join(:left, [u], l in Like, on: l.user_id == ^user_id and l.liked_user_id == u.id)
    |> where([u, l], is_nil(l.id))  # Only select users that haven't been liked by the current user
    |> Repo.all()
  end


end
