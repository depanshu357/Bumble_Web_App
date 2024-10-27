defmodule BumbleWebAppWeb.UpdateProfileLive.Show do
  use BumbleWebAppWeb, :live_view

  alias BumbleWebApp.Accounts


  @impl true
  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Update your charisma!
      <%!-- <:subtitle>Manage your account email address and password settings</:subtitle> --%>
    </.header>

    <div class="update-profile-buttons max-w-[1000px] w-screen mx-auto p-4 flex flex-row gap-4 justify-between flex-wrap md:flex-nowrap">
      <div class="w-full md:w-1/2">
        <div>
          <h3>Profile Photo</h3>
          <%= if @current_user.photo_url do %>
            <img
              src={@current_user.photo_url}
              alt="Profile Photo"
              class="h-[400px] w-full rounded-md object-cover shadow-lg"
            />
          <% else %>
            <div class="h-4 w-full">No profile photo uploaded</div>
          <% end %>
        </div>

        <div class="w-full">
          <.simple_form
            for={@photo_form}
            id="photo_form"
            phx-submit="update_photo"
            phx-change="change_photo"
          >
            <label class="relative ">
              <img
                src="/images/upload_icon.png"
                alt="Upload Icon"
                class="w-[30px] h-[30px] absolute left-[8px] top-[35px] cursor-pointer"
              />
              <.live_file_input
                upload={@uploads.photo}
                class="invisible p-0 m-0 w-[40px] h-8 mt-10 cursor-pointer"
              />
            </label>

            <%!-- <.input field={@photo_form[:photo_url]} type="file" label="Upload Profile Photo" /> --%>
            <:actions>
              <.button phx-disable-with="Uploading..." class="m-0 p-0 bg-yellow-400">
                Upload Photo
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
      <div class="w-full md:w-1/2">
        <.simple_form for={@name_form} id="name_form" phx-submit="update_name">
          <.input field={@name_form[:name]} type="text" label="Name" required />
          <:actions>
            <.button phx-disable-with="Changing...">Update Name</.button>
          </:actions>
        </.simple_form>
        <.simple_form for={@gender_form} id="gender_form" phx-submit="update_gender">
          <.input
            field={@gender_form[:gender]}
            type="select"
            class="mt-0"
            options={[{"Male", "Male"}, {"Female", "Female"}]}
          />
          <%!-- <:actions class="mt-0"> --%>
          <.button phx-disable-with="Changing...">Select Gender</.button>
          <%!-- </:actions> --%>
        </.simple_form>
        <.simple_form for={@age_form} id="age_form" phx-submit="update_age">
          <.input field={@age_form[:age]} type="number" label="Age" required />
          <:actions>
            <.button phx-disable-with="Changing...">Select Age</.button>
          </:actions>
        </.simple_form>
        <.simple_form for={@description_form} id="description_form" phx-submit="update_description">
          <.input field={@description_form[:description]} type="text" label="Description" required />
          <:actions>
            <.button phx-disable-with="Changing...">Update Description</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    <div class="max-w-[1000px] w-screen mt-2 mx-auto p-4">
      <h2 class="text-center font-bold">Select your interests</h2>
      <p class="text-center text-sm text-gray-500 mb-2">It will help in finding better people</p>
      <form phx-submit="update_interests" class="interests-list flex flex-row justify-between flex-wrap w-full gap-2" phx-submit="update_interests">
        <%= for interest <- @predefined_interests do %>
          <span
            phx-click="toggle_interest"
            phx-value-interest={interest}
            class={"hover:bg-gray-300 p-2 rounded-md border border-gray-300 cursor-pointer" <> if interest in @interests, do: " bg-yellow-500 text-white hover:bg-yellow-500", else: ""}
          >
            <%= interest %>
          </span>
        <% end %>
        <div class="w-full flex flex-row-reverse">
        <button type="submit"  phx-disable-with="Updating..." class="m-2 p-2 rounded-md text-white font-bold bg-yellow-500">
          Update Interests
        </button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
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
    name_changeset = Accounts.change_user_name(user)
    photo_form = Accounts.change_user_photo(user)
    gender_form = Accounts.change_user_gender(user)
    age_form = Accounts.change_user_age(user)
    interests = user.interests || []
    predefined_interests = ["📖 Reading", "🧳 Travelling", "⚽ Sports", "🎶 Music", "🍿 Movies", "🥘 Cooking", "🎨 Art", "📷 Photography", "🕹️ Gaming", "🌍 Environmental Activism", "🏕️ Camping", "🖥️ Tech & Coding", "✈️ Adventure", "🍽️ Food Tasting", "🚴 Biking", "🏋️ Fitness", "🌌 Stargazing", "✍️ Writing", "🎭 Theater", "🧘 Mindfulness", "🎤 Karaoke", "🐾 Animal Welfare", "📚 Self-Improvement", "🎲 Board Games","🌱 Gardening","🛶 Kayaking", "🚗 Road Trips", "🌄 Hiking", "🏄 Water Sports", "🏌️ Golf", "🧩 Puzzles", "🎳 Bowling", "🧵 Crafts & DIY", "🏛️ History", "🛍️ Fashion", "🏖️ Beach Days", "📜 Cultural Events", "🎉 Party Planning", "🎣 Fishing", "🚤 Boating", "🥂 Wine Tasting", "🎧 Podcasts", "🧗 Rock Climbing", "🛹 Skateboarding", "🖋️ Calligraphy", "🧙 Fantasy & Sci-Fi", "🎥 Filmmaking", "🎩 Magic Tricks", "🔬 Science Experiments"]

    IO.inspect(interests)
    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:description_form, to_form(description_changeset))
      |> assign(:name_form, to_form(name_changeset))
      |> assign(:photo_form, to_form(photo_form))
      |> assign(:gender_form, to_form(gender_form))
      |> assign(:age_form, to_form(age_form))
      |> assign(:interests, interests)
      |> assign(:predefined_interests, predefined_interests)
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

        description_form =
          Accounts.change_user_description(socket.assigns.current_user) |> to_form()

        {:noreply,
         socket

         |> put_flash(:info, "Description updated successfully.")
         |> assign(description_form: description_form)}

      {:error, %Ecto.Changeset{} = changeset} ->

        description_form = to_form(changeset)

        {:noreply,
         socket

         |> put_flash(:error, "Something went wrong. Please check the errors below.")
         |> assign(description_form: description_form)}
    end
  end

  def handle_event("update_name", %{"user" => user_params}, socket) do
    case Accounts.update_user_name(socket.assigns.current_user, user_params) do
      {:ok, _user} ->

        name_form =
          Accounts.change_user_name(socket.assigns.current_user) |> to_form()

        {:noreply,
         socket

         |> put_flash(:info, "Name updated successfully.")
         |> assign(name_form: name_form)}

      {:error, %Ecto.Changeset{} = changeset} ->

        name_form = to_form(changeset)

        {:noreply,
         socket

         |> put_flash(:error, "Something went wrong. Please check the errors below.")
         |> assign(name_form: name_form)}
    end
  end

  def handle_event("update_gender", %{"user" => user_params}, socket) do
    case Accounts.update_user_gender(socket.assigns.current_user, user_params) do
      {:ok, _user} ->

        gender_form =
          Accounts.change_user_gender(socket.assigns.current_user) |> to_form()

        {:noreply,
         socket

         |> put_flash(:info, "Gender updated successfully.")
         |> assign(gender_form: gender_form)}

      {:error, %Ecto.Changeset{} = changeset} ->

        gender_form = to_form(changeset)

        {:noreply,
         socket

         |> put_flash(:error, "Something went wrong. Please check the errors below.")
         |> assign(gender_form: gender_form)}
    end
  end

  def handle_event("validate_gender", %{"gender" => gender}, socket) do
    # Assign the selected gender to the socket's assigns
    gender_form = Map.put(socket.assigns.gender_form, :gender, gender)
    {:noreply, assign(socket, gender_form: gender_form)}
  end

  def handle_event("update_age", %{"user" => user_params}, socket) do
    case Accounts.update_user_age(socket.assigns.current_user, user_params) do
      {:ok, _user} ->

        age_form =
          Accounts.change_user_age(socket.assigns.current_user) |> to_form()

        {:noreply,
         socket

         |> put_flash(:info, "Age updated successfully.")
         |> assign(age_form: age_form)}

      {:error, %Ecto.Changeset{} = changeset} ->

        age_form = to_form(changeset)

        {:noreply,
         socket

         |> put_flash(:error, "Something went wrong. Please check the errors below.")
         |> assign(age_form: age_form)}
    end
  end

  @impl true
  def handle_event("toggle_interest", %{"interest" => interest}, socket) do
    interests = socket.assigns.interests

    # Toggle the interest in the list
    updated_interests =
      if interest in interests do
        interests -- [interest]  # Remove if already selected
      else
        [interest | interests]   # Add if not yet selected
      end

    {:noreply, assign(socket, :interests, updated_interests)}
  end

  def handle_event("update_interests", _params, socket) do
    current_user = socket.assigns.current_user
    interests = socket.assigns.interests

    # Update the user interests
    case Accounts.update_user_interests(current_user, %{"interests" => interests}) do
      {:ok, _user} ->
        {:noreply, put_flash(socket, :info, "Interests updated successfully.")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update interests.")}
    end
  end

end
