defmodule BlogApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BlogApi.Repo

  alias BlogApi.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    with {:ok, _uuid} <- Ecto.UUID.cast(id),
         %User{} = user <- Repo.get(User, id) do
      user
    else
      nil ->
        {:error, "Usuário não existe", 404}

      :error ->
        {:error, "Usuário não existe", 404}
    end
  end

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
