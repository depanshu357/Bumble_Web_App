defmodule BumbleWebAppWeb.ProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  # alias BumbleWebApp.Accounts
  alias BumbleWebApp.LikesAndMatches

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    # profiles = LikesAndMatches.list_of_profiles(user.id)
    profiles = sort_profiles(LikesAndMatches.list_of_profiles(user.id, 10), user)
    matches = LikesAndMatches.list_matches(user.id)
    current_profile = Enum.at(profiles, 0)
    dbg(matches)

    {:ok,
     assign(socket,
       profiles: profiles,
       user: user,
       matches: matches,
       current_profile: current_profile,
       current_profile_index: 0,
       selected_distance: 10
     )}
  end

  @impl true
  def handle_event("like", %{"liked_user_id" => liked_user_id}, socket) do
    user = socket.assigns.user

    is_match = false

    case LikesAndMatches.like_user(user.id, liked_user_id) do
      {:ok, _like} ->
        is_match =
          case LikesAndMatches.check_for_match(user.id, liked_user_id) do
            {:ok, :match} ->
              send(self(), {:match, liked_user_id})
              put_flash(socket, :info, "It's a match! You and the user have liked each other.")
              # Set is_match to true if there is a match
              true

            _ ->
              # Remains false if no match
              false
          end

        # Reload profiles after a like
        profiles = LikesAndMatches.list_of_profiles(user.id)
        matches = LikesAndMatches.list_matches(user.id)
        current_profile = Enum.at(profiles, 0)

        if is_match do
          {:noreply,
           socket
           |> assign(
             profiles: profiles,
             matches: matches,
             current_profile: current_profile,
             current_profile_index: 0
           )
           |> put_flash(:info, "You have a match!")}
        else
          {:noreply,
           assign(socket,
             profiles: profiles,
             matches: matches,
             current_profile: current_profile,
             current_profile_index: 0
           )}
        end

      # {:noreply,
      #   socket
      #   |> assign(profiles: profiles, matches: matches, current_profile: current_profile, current_profile_index: 0)
      # }
      # {:noreply, assign(socket, profiles: profiles, matches: matches, current_profile: current_profile, current_profile_index: 0)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error liking user.")}
    end
  end

  def sort_profiles(profiles, current_user) do
    Enum.sort_by(profiles, fn profile ->
      age_difference =
        if profile.age && current_user.age do
          abs(current_user.age - profile.age)
        else
          1000
        end

      mutual_interests_count = count_mutual_interests(current_user.interests, profile.interests)

      {-mutual_interests_count, age_difference, profile.distance}
    end)
  end

  defp count_mutual_interests(interests1, interests2) do
    Enum.count(interests1, fn interest -> interest in interests2 end)
  end

  def handle_event("next_profile", _params, socket) do
    new_index =
      min(socket.assigns.current_profile_index + 1, length(socket.assigns.profiles) - 1)

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

  def match_percentage(given_interests, user_interests) do
    # user_interests = ["hiking", "reading", "cooking", "swimming", "coding"]
    user_interests_count = length(user_interests)
    common_interests_count = count_mutual_interests(given_interests, user_interests)

    Float.round((common_interests_count / user_interests_count) * 100, 2)
  end

  @impl true
  def handle_event("update_distance", %{"distance" => distance}, socket) do
    dbg(distance)
    selected_distance = String.to_integer(distance)
    # socket = assign(socket, selected_distance: distance)
    profiles = LikesAndMatches.list_of_profiles(socket.assigns.user.id, selected_distance)
    display_distance = if selected_distance == 100 do
      "100+"
    else
      selected_distance
    end
    {:noreply,
      socket
      |> assign(selected_distance: display_distance)
      |> assign(current_profile: Enum.at(profiles, 0))
      |> assign(current_profile_index: 0)
      |> put_flash(:info, "Distance updated to #{display_distance} km.")
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row gap-2 w-screen">
      <div class="w-1/5 min-w-[300px] h-[100px] bg-yellow-50 h-screen p-2 border-r-2 border-grey-100">
        <%!-- <h2>Your Matches</h2> --%>
        <%= if @matches == [] do %>
          <p>No matches yet!</p>
        <% else %>
          <%= for match <- @matches do %>
            <.link navigate={"/chat/#{match.match_id}"}>
              <div class="flex flex-row bg-yellow-200 p-2 gap-2 mb-2 shadow-md max-h-[60px] overflow-hidden">
                <div class="rounded h-[60px] w-[50px]">
                  <img
                    src={match.photo_url}
                    alt="Match Profile Picture"
                    class="rounded-full h-[44px] w-[44px] object-cover object-center"
                  />
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
          <div class="m-2 flex flex-row gap-2 items-center">
            <label for="distance_slider">
              Distance: <span class="text-yellow-500"><%= @selected_distance %> km</span>
            </label>
            <form phx-change="update_distance">
              <input
                type="range"
                min="0"
                max="100"
                step="1"
                name="distance"
                value={@selected_distance}
                phx-debounce="300"
                id="distance_slider"
                class="w-full h-2 bg-yellow-400 rounded-md appearance-none cursor-pointer accent-yellow-600"
              />
            </form>
          </div>
          <div class="relative max-w-[1000px] h-[80vh] m-2">
            <div class="relative max-w-[1000px] h-[80vh] border-2 border-yellow-400 rounded-lg flex flex-row overflow-hidden shadow-lg">
              <div class="h-full w-3/5 relative">
                <h2 class="font-bold text-4xl absolute top-2 left-2 text-white [text-shadow:2px_2px_2px_var(--tw-shadow-color)] shadow-black">
                  <%= @current_profile.name %>
                  <span class="text-xl"><%= @current_profile.age %></span>
                </h2>
                <img
                  src={@current_profile.photo_url}
                  alt="Profile picture"
                  class="h-full w-full object-cover"
                />
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
                <div>
                  <span class="text-gray-500"><%= @current_profile.gender %></span>
                  <span class="text-gray-500 text-sm font-bold"><%= @current_profile.age %></span>
                </div>
                <span>
                  Distance: <%= if @current_profile.distance == nil do
                    0
                  else
                    Float.floor(@current_profile.distance, 0) |> trunc()
                  end %> km
                </span>
                <p><%= @current_profile.description %></p>
                <div>
                  <div>
                    <span > Match Percentage: </span> <span class="font-bold"> <%= match_percentage(@current_profile.interests,@current_user.interests) %>% </span>
                  </div>
                  <span class="font-bold">Interests:</span>
                  <ul>
                    <%= for interest <- @current_profile.interests do %>
                      <li><%= interest %></li>
                    <% end %>
                  </ul>
                </div>
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
