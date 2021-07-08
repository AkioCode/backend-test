defmodule BlogApiWeb.UserView do
  use BlogApiWeb, :view

  def render("index.json", %{users: users}) do
    render_many(users, BlogApiWeb.UserView, "show.json")
  end

  def render("show.json", %{user: user}) do
    %{
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      image: user.image
    }
  end
end
  