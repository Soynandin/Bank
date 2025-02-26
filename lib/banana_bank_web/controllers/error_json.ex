defmodule BananaBankWeb.ErrorJSON do

  # Renderiza uma mensagem de erro com base no template
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  # Retorna uma mensagem de erro quando o usuário não for encontrado
  def error(%{status: :not_found}) do
    %{status: :not_found, message: "Usuário não encontrado."}
  end

  # Processa e traduz os erros do changeset
  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  # Traduz o erro usando a chave e o valor do changeset
  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
