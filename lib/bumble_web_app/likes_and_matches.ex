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
        %Match{}
        |> Match.matches_changeset(%{user1_id: user_id, user2_id: liked_user_id})
        |> Repo.insert()
        {:ok, :match}
        # Repo.insert(%Match{user1_id: user_id, user2_id: liked_user_id})
        {:ok, :match}
    end
  end

  def list_of_profiles(user_id, distance \\ 10) do
    user = Repo.get!(User, user_id)

    User
    |> where([u], u.id != ^user_id)
    |> join(:left, [u], l in Like, on: l.user_id == ^user_id and l.liked_user_id == u.id)
    |> where([_u, l], is_nil(l.id))
    # |> where([u], is_nil(u.gender) or is_nil(^user.gender) or u.gender != ^user.gender)
    |> where([u], fragment(
      "earth_distance(ll_to_earth(?, ?), ll_to_earth(?, ?)) <= ? * 1000",
      u.latitude, u.longitude, ^user.latitude, ^user.longitude, ^distance
    ))
    |> select([u], %{
        id: u.id,
        name: u.name,
        description: u.description,
        photo_url: u.photo_url,
        gender: u.gender,
        interests: u.interests,
        age: u.age,
        distance: fragment(
          "earth_distance(ll_to_earth(?, ?), ll_to_earth(?, ?)) / 1000",
          u.latitude, u.longitude, ^user.latitude, ^user.longitude
        )
      })
    |> Repo.all()
  end


  def list_matches(user_id) do
    # Fetch the current user's latitude and longitude

    # Query matches and calculate distance
    from(m in Match,
      join: u in User,
      on: u.id == m.user1_id or u.id == m.user2_id,
      where: m.user1_id == ^user_id or m.user2_id == ^user_id,
      where: u.id != ^user_id, # Avoid returning the current user's data
      select: %{
        user_id: u.id,
        description: u.description,
        photo_url: u.photo_url,
        match_id: m.id,
        name: u.name,
        gender: u.gender,
        interests: u.interests,
        age: u.age,
      }
    )
    |> Repo.all()
  end


end
