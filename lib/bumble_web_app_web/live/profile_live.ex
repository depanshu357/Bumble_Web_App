defmodule BumbleWebAppWeb.ProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  # alias BumbleWebApp.Accounts
  alias BumbleWebApp.LikesAndMatches

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profiles = LikesAndMatches.list_of_profiles(user.id)

    {:ok, assign(socket, profiles: profiles, user: user)}
  end

  @impl true
  def handle_event("like", %{"liked_user_id" => liked_user_id}, socket) do
    user = socket.assigns.user

    case LikesAndMatches.like_user(user.id, liked_user_id) do
      {:ok, _like} ->
        case LikesAndMatches.check_for_match(user.id, liked_user_id) do
          {:ok, :match} ->
            send(self(), {:match, liked_user_id})

          _ -> :ok
        end

        # Reload profiles after a like
        profiles = LikesAndMatches.list_of_profiles(user.id)
        {:noreply, assign(socket, profiles: profiles)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error liking user.")}
    end
  end

  @impl true
  def handle_info({:match, liked_user_id}, socket) do
    put_flash(socket, :info, "You've matched with user #{liked_user_id}!")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Profiles for liking</h1>
      <%= for profile <- @profiles do %>
        <div>
          <img src={profile.photo_url} alt="Profile picture" />
          <p><%= profile.description %></p>

          <button phx-click="like" phx-value-liked_user_id={profile.id}
           class="p-4 py-2 bg-black text-white rounded"
          >Like</button>
        </div>
      <% end %>
    </div>
    """
  end

  # defp page_title(:show), do: "Show Profile"
  # defp page_title(:edit), do: "Edit Profile"
end
