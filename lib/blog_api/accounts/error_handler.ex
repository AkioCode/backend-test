defmodule BlogApi.Accounts.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    message =
      case type do
        :invalid_token ->
          "Token inválido ou expirado"
        :no_resource_found ->
          "Token não encontrado"
        :unauthorized ->
          "Desautorizado"
        _ ->
          "Token não encontrado"
      end

    body = Jason.encode!(%{message: message})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
