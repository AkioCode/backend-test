defmodule BlogApiWeb.Router do
  use BlogApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogApiWeb do
    pipe_through :api

    post "/user", UserController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogApiWeb do
  #   pipe_through :api
  # end
end
