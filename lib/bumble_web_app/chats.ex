defmodule BumbleWebApp.Chats do
  alias BumbleWebApp.Repo
  import Ecto.Query, only: [from: 2]
  alias BumbleWebApp.Chats.Chat

  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.chats_changeset(attrs)
    |> Repo.insert()
  end

  def list_chats(match_id) do
    query = from c in Chat,
    where: c.match_id == ^match_id
    # order_by: [asc: c.sent_at],
    # preload: [:sender_id]
    Repo.all(query)
  end

end
