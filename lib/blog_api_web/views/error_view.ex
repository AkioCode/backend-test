defmodule BlogApiWeb.ErrorView do
  use BlogApiWeb, :view
  alias Ecto.Changeset

  def render("errors.json", %{result: %Changeset{} = changeset}),
  do: %{message: translate_errors(changeset)}

  def render("errors.json", %{result: message}),
    do: %{message: message}

  defp translate_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
