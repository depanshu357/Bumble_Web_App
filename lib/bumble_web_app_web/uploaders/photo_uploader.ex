defmodule BumbleWebAppWeb.Uploaders.PhotoUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]  # You can define different versions like thumbnail if needed

  # Define the storage directory
  def store_dir(version, {file, user}) do
    "uploads/users/#{user.id}/photos"
  end

  # Optionally, define allowed file types
  def validate({file, _user}) do
    ~w(.jpg .jpeg .png .gif) |> Enum.member?(Path.extname(file.file_name))
  end
end
