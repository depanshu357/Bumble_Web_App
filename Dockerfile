# Use the official Elixir image
FROM elixir:1.17.3

# Set environment variables
ENV MIX_ENV=prod
ENV PORT=4000

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Install build dependencies
RUN apt-get update && \
    apt-get install -y postgresql-client

# Create app directory
WORKDIR /app

# Install project dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get 

# create tables
RUN mix ecto.create

RUN mix ecto.migrate

# Compile the application
COPY . .
RUN mix compile

# Build the Phoenix app assets
RUN mix assets.deploy

# Generate the release
RUN mix release

# Expose the port
EXPOSE 4000

# Start the release
CMD ["_build/prod/rel/bumble_web_app/bin/bumble_web_app", "start"]
