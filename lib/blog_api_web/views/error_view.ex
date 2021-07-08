defmodule BlogApiWeb.ErrorView do
  use BlogApiWeb, :view
  alias Ecto.Changeset

  def render("errors.json", %{
        result: %Changeset{
          errors: [
            email: {message, [constraint: :unique, constraint_name: "users_email_index"]}
          ]
        }
      }) do
    %{message: message}
  end

  def render("errors.json", %{result: %Changeset{} = changeset}) do
    %{message: translate_errors(changeset)}
  end

  def render("errors.json", %{result: message}),
    do: %{message: message}

  defp translate_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}\"#{k}\" #{joined_errors}"
    end)
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
