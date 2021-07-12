defmodule BlogApiWeb.Router do
  use BlogApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BlogApi.Accounts.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", BlogApiWeb do
    pipe_through [:api, :auth]

    post "/user", UserController, :create
    post "/login", UserController, :login
  end

  scope "/", BlogApiWeb do
    pipe_through [:api, :auth, :ensure_auth]

    resources "/user", UserController, only: [:index, :show, :delete]
    resources "/post", PostController, only: [:index, :show, :create, :update, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogApiWeb do
  #   pipe_through :api
  # end
end
