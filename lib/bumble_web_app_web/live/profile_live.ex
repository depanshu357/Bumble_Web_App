defmodule BumbleWebAppWeb.ProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  alias BumbleWebApp.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

 def render(assigns) do
    ~H"""
    <div>
      <h1>Profiles</h1>
    </div>
    """
  end

  defp page_title(:show), do: "Show Profile"
  defp page_title(:edit), do: "Edit Profile"
end
