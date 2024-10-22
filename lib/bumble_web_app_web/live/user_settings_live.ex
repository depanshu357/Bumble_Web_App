defmodule BumbleWebAppWeb.UserSettingsLive do
  use BumbleWebAppWeb, :live_view

  alias BumbleWebApp.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <h3>Profile Photo</h3>
        <%= if @current_user.photo_url do %>
          <img
            src={@current_user.photo_url}
            alt="Profile Photo"
            class="h-24 w-24 rounded-full object-cover"
          />
        <% else %>
          <p>No profile photo uploaded</p>
        <% end %>
      </div>

      <div>
        <.simple_form
          for={@photo_form}
          id="photo_form"
          phx-submit="update_photo"
          phx-change="change_photo"
        >
          <.live_file_input upload={@uploads.photo} />

          <%!-- <.input field={@photo_form[:photo_url]} type="file" label="Upload Profile Photo" /> --%>
          <:actions>
            <.button phx-disable-with="Uploading...">Upload Photo</.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.simple_form for={@description_form} id="description_form" phx-submit="update_description">
          <.input field={@description_form[:description]} type="text" label="Description" required />
          <:actions>
            <.button phx-disable-with="Changing...">Change Description</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    description_changeset = Accounts.change_user_description(user)
    photo_form = Accounts.change_user_photo(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:description_form, to_form(description_changeset))
      |> assign(:photo_form, to_form(photo_form))
      |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("change_photo", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("update_photo", _params, socket) do
    # Ensure the directory exists
    uploads_dir = "priv/static/uploads/photos"
    # Creates the directory if it doesn't exist
    File.mkdir_p!(uploads_dir)

    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        extension = ".png"
         # Ensure the destination path includes the appropriate extension
        dest = Path.join("priv/static/uploads/photos", Path.basename(path) <> extension)

        # Copy the file and return the path
        File.cp!(path, dest)
        # Return the relative path to be stored in photo_url
        "/uploads/photos/#{Path.basename(path) <> extension}"
      end)


    # Get the image URL if the upload was successful
    case uploaded_files do
      [photo_url] ->
        # Update the user with the new photo URL
        case Accounts.update_user_photo(socket.assigns.current_user, %{"photo_url" => photo_url}) do
          {:ok, _user} ->
            {:noreply,
             socket
             |> put_flash(:info, "Profile photo updated successfully.")
             |> assign(
               photo_form: to_form(Accounts.change_user_photo(socket.assigns.current_user)),
               current_user: %{socket.assigns.current_user | photo_url: photo_url}
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error updating profile photo.")
             |> assign(photo_form: to_form(changeset))}
        end

      [] ->
        {:noreply, socket |> put_flash(:error, "No file was uploaded.")}
    end
  end

  def handle_event("update_description", %{"user" => user_params}, socket) do
    case Accounts.update_user_description(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        # Successful update, re-render the form with a new empty changeset
        description_form =
          Accounts.change_user_description(socket.assigns.current_user) |> to_form()

        {:noreply,
         socket
         # Success message
         |> put_flash(:info, "Description updated successfully.")
         |> assign(description_form: description_form)}

      {:error, %Ecto.Changeset{} = changeset} ->
        # On error, re-render the form with the errors in the changeset
        description_form = to_form(changeset)

        {:noreply,
         socket
         # Error message
         |> put_flash(:error, "Something went wrong. Please check the errors below.")
         |> assign(description_form: description_form)}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
