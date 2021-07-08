defmodule BlogApiWeb.PageController do
  use BlogApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
