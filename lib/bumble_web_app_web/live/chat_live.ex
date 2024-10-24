defmodule BumbleWebAppWeb.ChatLive.Show do
  use BumbleWebAppWeb, :live_view
  alias Phoenix.PubSub
  alias BumbleWebApp.Chats
  alias BumbleWebApp.LikesAndMatches

  @impl true
  def mount(%{"match_id" => match_id}, _session, socket) do
    user = socket.assigns.current_user
    matches = LikesAndMatches.list_matches(user.id)
    chat_id = match_id
    topic = "chat_room:#{chat_id}"
    chats = Chats.list_chats(match_id)

    # Subscribe to PubSub topic for real-time chat
    PubSub.subscribe(BumbleWebApp.PubSub, topic)

    # Load existing messages or create an empty list
    {:ok,
     assign(socket,
       chat_topic: topic,
       matches: matches,
       match_id: match_id,
       user: user,
       chats: chats
     )}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    user = socket.assigns.current_user
    match_id = socket.assigns.match_id

    case Chats.create_chat(%{
           match_id: match_id,
           sender_id: user.id,
           message: message
         }) do
      {:ok, _chat} ->
        BumbleWebAppWeb.Endpoint.broadcast!("chat_room:#{match_id}", "new_message", %{
          message: message,
          user_id: user.id
        })

        {:noreply, assign(socket, message: "")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to send message.")}
    end
  end

  @impl true
  def handle_info(
        %{event: "new_message", payload: %{message: _message, user_id: _user_id}},
        socket
      ) do
    # Fetch updated chat messages from the database
    chats = Chats.list_chats(socket.assigns.match_id)

    {:noreply, assign(socket, chats: chats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row w-screen">
      <div class="w-1/5 min-w-[300px] h-[100px] bg-yellow-50 h-screen p-2 border-r-2 border-grey-100">
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
                  <%!-- <span><%= match.id %></span> --%>
                  <p><%= match.description %></p>
                </div>
              </div>
            </.link>
          <% end %>
        <% end %>
      </div>
      <div class="w-4/5 mx-auto relative h-[90vh] rounded flex flex-col justify-between  overflow-y-scroll">

          <h1 class="font-bold text-lg text-center sticky top-1">Let's Gossip</h1>
          <div class="h-full ">
            <%= for chat <- @chats do %>
              <div class={if chat.sender_id == @user.id, do: "message message-sent", else: "message message-received"}>
                <span><%= chat.message %></span>
                <%!-- <small><%= if chat.sender_id == @user.id, do: "You", else: "Matched User" %></small> --%>
              </div>
            <% end %>
          </div>

          <form phx-submit="send_message" class="sticky w-full bottom-0 gap-2 flex flex-row p-4 bg-white">
            <input type="text" name="message" placeholder="Start Chatting..." class="border-yellow-400 border-2 w-10/12 border-grey-100 rounded-lg" />
            <button type="submit" class="send-button w-2/12 bg-yellow-500 rounded text-white">Send</button>
          </form>
      </div>
    </div>
    """
  end
end
