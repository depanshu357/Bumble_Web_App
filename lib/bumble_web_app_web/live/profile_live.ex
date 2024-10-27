defmodule BumbleWebAppWeb.ProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  # alias BumbleWebApp.Accounts
  alias BumbleWebApp.LikesAndMatches

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profiles = LikesAndMatches.list_of_profiles(user.id)
    matches = LikesAndMatches.list_matches(user.id)
    current_profile = Enum.at(profiles, 0)
    dbg(matches)

    {:ok,
     assign(socket,
       profiles: profiles,
       user: user,
       matches: matches,
       current_profile: current_profile,
       current_profile_index: 0)}
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
        current_profile = Enum.at(profiles, 0)
        {:noreply, assign(socket, profiles: profiles, matches: matches, current_profile: current_profile, current_profile_index: 0)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error liking user.")}
    end
  end

  @impl true
  def handle_event("next_profile", _params, socket) do
    new_index = min(socket.assigns.current_profile_index + 1, length(socket.assigns.profiles) - 1)
    current_profile = Enum.at(socket.assigns.profiles, new_index)
    {:noreply, assign(socket, current_profile_index: new_index, current_profile: current_profile)}
  end

  @impl true
  def handle_event("prev_profile", _params, socket) do
    new_index = max(socket.assigns.current_profile_index - 1, 0)
    current_profile = Enum.at(socket.assigns.profiles, new_index)
    {:noreply, assign(socket, current_profile_index: new_index, current_profile: current_profile)}
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
      <%!-- <h2>Your Matches</h2> --%>
      <%= if @matches == [] do %>
        <p>No matches yet!</p>
      <% else %>
        <%= for match <- @matches do %>
          <.link navigate={"/chat/#{match.match_id}"}>
            <div class="flex flex-row bg-yellow-200 p-2 gap-2 mb-2 shadow-md max-h-[60px] overflow-hidden">
              <div class="rounded h-[60px]">
                <img src={match.photo_url} alt="Match Profile Picture" class="rounded-full h-[44px] w-[44px] object-cover" />
              </div>
              <div>
                <span class="font-bold"><%= match.name %></span>
                <p class="text-gray-500"><%= match.description %></p>
              </div>
            </div>
          </.link>
        <% end %>
      <% end %>
    </div>

    <div class="w-full max-w-[1000px] mx-auto mt-12">
      <%= if length(@profiles) == 0 do %>
        <p class="font-bold m-auto text-xl text-center">No more profiles to show!</p>
      <% else %>
        <%!-- <%= profile = Enum.at(@profiles, @current_profile_index) %> --%>
        <div class="relative max-w-[1000px] h-[80vh] m-2">
          <div class="relative max-w-[1000px] h-[80vh] border-2 border-yellow-400 rounded-lg flex flex-row overflow-hidden">
            <div class="h-full w-3/5 relative">
              <img src={@current_profile.photo_url} alt="Profile picture" class="h-full w-full object-cover" />
              <button
            phx-click="next_profile"
            phx-value-liked_user_id={@current_profile.id}
            class="p-4 bg-yellow-500 text-white rounded-full absolute bottom-4 transform left-[5%]"
          >
            <img src="/images/close_icon.png" class="w-[40px]" />
          </button>
          <button
            phx-click="like"
            phx-value-liked_user_id={@current_profile.id}
            class="p-4 bg-yellow-500 text-white rounded-full absolute bottom-4 transform right-[5%]"
          >
            <img src="/images/check_icon.png" class="w-[40px]" />
          </button>
            </div>
            <div class="bg-yellow-100 w-2/5 flex flex-col  p-4">
              <h2 class="font-bold text-2xl"><%= @current_profile.name %></h2>
              <span class="text-gray-500"><%= @current_profile.gender %></span>
              <p><%= @current_profile.description %></p>
            </div>
          </div>

        </div>

        <%!-- <div class="flex justify-between mt-4">
          <button
            phx-click="prev_profile"
            class="p-2 bg-gray-300 rounded">
            Previous
          </button>

          <button
            phx-click="next_profile"
            class="p-2 bg-gray-300 rounded">
            Next
          </button>
        </div> --%>
      <% end %>
    </div>
  </div>
  """
end


  # defp page_title(:show), do: "Show Profile"
  # defp page_title(:edit), do: "Edit Profile"
end
