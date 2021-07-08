defmodule BlogApi.Accounts.Session do
  alias BlogApi.Accounts
  alias BlogApi.Accounts.Guardian
  alias BlogApi.Accounts.User

  def login(%{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- authenticate(email, password),
         {:ok, token, _claims} <- Guardian.sign_in(user) do
      {:ok, token}
    end
  end

  def authenticate(email, password) do
    Accounts.get_user_by_email(email)
    |> case do
      nil ->
        {:error, "Campos inválidos"}

      user ->
        if password == user.password do
          {:ok, user}
        else
          {:error, "Campos inválidos"}
        end
    end
  end
end
