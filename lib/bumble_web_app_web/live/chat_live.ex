defmodule BumbleWebAppWeb.ChatLive.Show do
  use BumbleWebAppWeb, :live_view
  alias Phoenix.PubSub
  alias BumbleWebApp.Chats

  @impl true
  def mount(%{"match_id" => match_id}, _session, socket) do
    user = socket.assigns.current_user
    chat_id = match_id
    topic = "chat_room:#{chat_id}"
    chats = Chats.list_chats(match_id)

    # Subscribe to PubSub topic for real-time chat
    PubSub.subscribe(BumbleWebApp.PubSub, topic)

    # Load existing messages or create an empty list
    {:ok, assign(socket, chat_topic: topic, chat_messages: [], match_id: match_id, user: user, chats: chats)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    user = socket.assigns.current_user
    match_id = socket.assigns.match_id

    case Chats.create_chat(%{
           match_id: match_id,
           sender_id: user.id,
           message: message,
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
  def handle_info(%{event: "new_message", payload: %{message: message, user_id: user_id}}, socket) do
    # Fetch updated chat messages from the database
    chats = Chats.list_chats(socket.assigns.match_id)

    {:noreply, assign(socket, chats: chats)}
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div class="chat-page">
      <h1>Chat Room</h1>
      <%!-- <div class="messages">
        <%= for message <- Enum.reverse(@chat_messages) do %>
          <p><%= message %></p>
        <% end %>
      </div> --%>
      <div>
        <%= for chat <- @chats do %>
        <div class={if chat.sender_id == @user.id, do: "message-sent", else: "message-received"}>
          <p><%= chat.message %></p>
          <small><%= if chat.sender_id == @user.id, do: "You", else: "Matched User" %></small>
        </div>
        <% end %>
      </div>

      <form phx-submit="send_message" class="send-message-form">
        <input type="text" name="message" placeholder="Type your message" class="input-field" />
        <button type="submit" class="send-button">Send</button>
      </form>
    </div>
    """
  end
end
