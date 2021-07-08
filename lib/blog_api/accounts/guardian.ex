defmodule BlogApi.Accounts.Guardian do
  use Guardian, otp_app: :blog_api

  alias BlogApi.Accounts

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = Accounts.get_user!(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def sign_in(%Accounts.User{} = user),
    do: Guardian.encode_and_sign(__MODULE__, user)

  def verify(token), do: Guardian.decode_and_verify(__MODULE__, token)
end
