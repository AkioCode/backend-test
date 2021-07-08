defmodule BlogApiWeb.FallbackController do
  use BlogApiWeb, :controller

  def call(conn, {:error, result, status_code})
      when is_atom(status_code) or is_integer(status_code) do
    conn
    |> put_status(status_code)
    |> put_view(BlogApiWeb.ErrorView)
    |> render("errors.json", result: result)
  end

  def call(conn, {:error, result}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogApiWeb.ErrorView)
    |> render("errors.json", result: result)
  end
end
