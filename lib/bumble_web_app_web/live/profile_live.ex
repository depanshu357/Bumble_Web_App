defmodule BumbleWebAppWeb.ProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  # alias BumbleWebApp.Accounts
  alias BumbleWebApp.LikesAndMatches

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profiles = LikesAndMatches.list_of_profiles(user.id)
    matches = LikesAndMatches.list_matches(user.id)
    dbg(matches)

    {:ok, assign(socket, profiles: profiles, user: user, matches: matches)}
  end

  @impl true
  def handle_event("like", %{"liked_user_id" => liked_user_id}, socket) do
    user = socket.assigns.user

    case LikesAndMatches.like_user(user.id, liked_user_id) do
      {:ok, _like} ->
        case LikesAndMatches.check_for_match(user.id, liked_user_id) do
          {:ok, :match} ->
            send(
              self(),
              {:match, liked_user_id}
            )

          _ ->
            :ok
        end

        # Reload profiles after a like
        profiles = LikesAndMatches.list_of_profiles(user.id)
        matches = LikesAndMatches.list_matches(user.id)
        {:noreply, assign(socket, profiles: profiles, matches: matches)}

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
    <div class="flex flex-row gap-2 w-screen">
      <div class="w-1/5 h-[100px] bg-yellow-50 h-screen p-2 border-r-2 border-grey-100">
        <h2>Your Matches</h2>
        <%= if @matches == [] do %>
          <p>No matches yet!</p>
        <% else %>
          <%= for match <- @matches do %>
            <.link navigate={"/chat/#{match.match_id}"}>
              <div class="flex flex-row bg-yellow-100 p-2 gap-2">
                <div class="rounded h-[60px]">
                  <img src={match.photo_url} alt="Match Profile Picture" class="rounded h-[60px]" />
                </div>
                <div>
                  <span> Matched with </span>
                  <%!-- <span><%= match.id %></span> --%>
                  <p><%= match.description %></p>
                </div>
              </div>
            </.link>
          <% end %>
        <% end %>
      </div>
      <div class="w-full max-w-[1000px] mx-auto m-auto">
        <%!-- <h1>Profiles for liking</h1> --%>
        <%= for profile <- @profiles do %>
        <div class="relative max-w-[800px] h-[80vh]">
          <div class="relative max-w-[800px] h-[80vh] border-2 border-yellow-400 rounded-lg flex flex-row overflow-hidden">
            <div class="h-full w-3/5">
              <img src={profile.photo_url} alt="Profile picture" class="h-full w-full" />
            </div>
            <div class="bg-yellow-100 w-2/5 flex items-center">
              <p><%= profile.description %></p>


            </div>
          </div>
          <%!-- <button
                phx-click="like"
                phx-value-liked_user_id={profile.id}
                class="p-4 py-2 bg-yellow-500 text-white rounded-full absolute bottom-2 transform translate-x-1/2 left-1/2"
              >
                <img src="/images/check_icon.png" class="w-[40px]"/>
              </button> --%>
          <button
                phx-click="like"
                phx-value-liked_user_id={profile.id}
                class="p-4 py-2 bg-yellow-500 text-white rounded-full absolute -bottom-6 transform translate-x-1/2 left-[60%]"
              >
                <img src="/images/check_icon.png" class="w-[40px]"/>
              </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # defp page_title(:show), do: "Show Profile"
  # defp page_title(:edit), do: "Edit Profile"
end
