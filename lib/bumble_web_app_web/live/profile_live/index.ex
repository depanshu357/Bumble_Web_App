defmodule BumbleWebAppWeb.ProfileLive.Index do
  use BumbleWebAppWeb, :live_view

  alias BumbleWebApp.Accounts
  alias BumbleWebApp.Accounts.Profile

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    changeset = Accounts.change_user(current_user)
    {:ok, assign(socket, current_user: current_user, changeset: changeset)}
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, Accounts.get_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Profile")
    |> assign(:profile, %Profile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({BumbleWebAppWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Accounts.get_profile!(id)
    {:ok, _} = Accounts.delete_profile(profile)

    {:noreply, stream_delete(socket, :profiles, profile)}
  end
end
