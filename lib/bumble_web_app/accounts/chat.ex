defmodule BumbleWebApp.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :message, :string
    field :match_id, :integer
    field :sender_id, :integer

    timestamps()
  end

  @doc false
  def chats_changeset(chat, attrs) do
    chat
    |> cast(attrs, [:message, :match_id, :sender_id])
    |> validate_required([:message, :match_id, :sender_id])
  end
end
