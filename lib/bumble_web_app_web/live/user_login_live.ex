defmodule BumbleWebAppWeb.UserLoginLive do
  use BumbleWebAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-[1000px] w-screen h-[50vh] mx-auto mt-12 rounded-md overflow-hidden flex flex-row shadow-lg">
      <div class="w-1/2 bg-yellow-300">
        <img src="/images/bumble_wide.png" alt="Login" class="object-cover w-full h-full" />
      </div>
      <div class="w-1/2 flex flex-col justify-center mx-auto max-w-sm p-4">
        <.header class="text-center">
          Log in to account
          <:subtitle>
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="font-semibold text-yellow-500 hover:underline"
            >
              Sign up
            </.link>
            for an account now.
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link href={~p"/users/reset_password"} class="text-sm text-yellow-500 font-semibold">
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full bg-yellow-400">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
