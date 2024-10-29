# Bumble Web App

The Bumble Web App is a real-time, interactive platform that allows users to connect based on mutual interests. Users can create and update profiles, like or reject other users, and chat in real-time once they've matched. This app is built with Elixir and Phoenix LiveView to offer a dynamic user experience, especially for profile customization and interest selection.

## Features

- **User Authentication**: Secure login and registration system.
- **Profile Management**: Users can edit their profile information, including name, gender, description, profile photo, and interests.
- **Interest Selection**: Users can choose multiple interests from a list of chips to personalize their profile.
- **Matching and Chat**: If two users mutually like each other, they can start a real-time conversation.
- **Real-Time Updates**: Phoenix LiveView keeps user interactions responsive and up-to-date without page reloads.
- **Location-based Distance Calculation**: Each profile shows the distance from your location.

## App Showcase

#### Profile Update
<img src="/images_for_readme/profile_updation_page.png" alt="profile upload" width="60%"/>
Easily update your profile details, including name, description, and profile photo. Users can also select specific interests to match with others who share similar preferences.

#### Profile Selection
<!-- ![Profile Selection](/images_for_readme/profile_selection_page.png) -->
<img src="/images_for_readme/profile_selection_page.png" alt="profile selection" width="60%" />
Swipe through other user profiles one at a time, and choose to like or reject them based on your interest. The app shows the distance between you and other users, giving you location-based suggestions.


#### Real-Time Chat
<!-- ![Real-Time Chat](/images_for_readme/real_time_chat.png) -->
<img src="/images_for_readme/real_time_chat.png" alt="real time chat" width="60%" />
Once you’ve matched with another user, engage in a seamless, real-time chat. Messages are updated instantly, making conversations feel dynamic and responsive.

---

## Setup Instructions

### Prerequisites

Ensure you have the following installed on your machine:

- **Elixir** (version 1.17.3 or above)
- **Phoenix** (version 1.6 or above)
- **PostgreSQL** (for database management)

Please use a linux(ubuntu specifically) envivronment if possible

### Installation

1. **Clone the Repository**

   ```bash
   git clone -b master https://github.com/depanshu357/Bumble_Web_App.git   
   cd bumble_web_app
   ```

2. **Install Dependencies**

   ```bash
   mix deps.get
   ```

3. **Set up database** 
   Make sure to change the credentials to connect to database in config/dev.exs file  
   ```bash
   mix ecto.setup
   ```

4. **Run the web app**

   ```bash
   mix phx.server
   ```
