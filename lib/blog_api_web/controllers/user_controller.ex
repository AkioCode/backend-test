defmodule BlogApiWeb.UserController do
  use BlogApiWeb, :controller
  alias BlogApi.Accounts
  alias Accounts.{Guardian, Session}

  action_fallback BlogApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.create_user(user_params) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:ok)
      |> json(%{token: token})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def login(conn, %{"email" => "", "password" => _password}),
    do: {:error, "\"email\" is not allowed to be empty"}

  def login(conn, %{"email" => _email, "password" => ""}),
    do: {:error, "\"password\" is not allowed to be emmty"}

  def login(conn, %{"email" => _email, "password" => _password} = credentials) do
    with {:ok, token} <- Session.login(credentials) do
      conn
      |> put_status(:ok)
      |> json(%{token: token})
    end
  end

  def login(conn, %{"password" => _password}), do: {:error, "\"email\" is required"}

  def login(conn, %{"email" => _email}), do: {:error, "\"password\" is required"}
end
