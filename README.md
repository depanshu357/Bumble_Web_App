# Bumble Web App

The Bumble Web App is a real-time, interactive platform that allows users to connect based on mutual interests. Users can create and update profiles, like or reject other users, and chat in real-time once they've matched. This app is built with Elixir and Phoenix LiveView to offer a dynamic user experience, especially for profile customization and interest selection.

## Features

- **User Authentication**: Secure login and registration system.
- **Profile Management**: Users can edit their profile information, including name, gender, description, profile photo, and interests.
- **Interest Selection**: Users can choose multiple interests from a list of chips to personalize their profile.
- **Matching and Chat**: If two users mutually like each other, they can start a real-time conversation.
- **Real-Time Updates**: Phoenix LiveView keeps user interactions responsive and up-to-date without page reloads.

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
