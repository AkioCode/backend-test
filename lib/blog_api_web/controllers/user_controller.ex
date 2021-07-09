defmodule BlogApiWeb.UserController do
  use BlogApiWeb, :controller
  alias BlogApi.Accounts
  alias Accounts.{Guardian, Session, User}

  action_fallback BlogApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.create_user(user_params) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:ok)
      |> json(%{token: token})
    end
  end

  def show(conn, %{"id" => "me"}) do
    user = Guardian.current_user(conn)
    render(conn, "show.json", %{user: user})
  end

  def show(conn, %{"id" => id}) do
    with %User{} = user <- Accounts.get_user(id) do
      render(conn, "show.json", %{user: user})
    end
  end

  def edit(conn, %{"id" => id}) do
    %User{} = user = Accounts.get_user(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    %User{} = user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => "me"}) do
    %User{} = user = Guardian.current_user(conn)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_status(204)
    |> text("")
  end

  def login(_conn, %{"email" => "", "password" => _password}),
    do: {:error, "\"email\" is not allowed to be empty"}

  def login(_conn, %{"email" => _email, "password" => ""}),
    do: {:error, "\"password\" is not allowed to be emmty"}

  def login(conn, %{"email" => _email, "password" => _password} = credentials) do
    with {:ok, token} <- Session.login(credentials) do
      conn
      |> put_status(:ok)
      |> json(%{token: token})
    end
  end

  def login(_conn, %{"password" => _password}), do: {:error, "\"email\" is required"}

  def login(_conn, %{"email" => _email}), do: {:error, "\"password\" is required"}
end
