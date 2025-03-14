defmodule BananaBank.Users.Update do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Atualiza um usuário pelo ID
  def call(%{id: id} = params) do
    id = String.to_integer(to_string(id)) # Converte ID para inteiro

    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> update(user, params)
    end
  end

  # Aplica as mudanças e atualiza o usuário no banco
  defp update(user, params) do
    user
    |> User.update_changeset(params) # Valida e aplica as mudanças
    |> Repo.update()
    |> handle_update_result()
  end

  # Processa o resultado do update
  defp handle_update_result({:ok, user}), do: {:ok, user}

  defp handle_update_result({:error, changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    {:error, %{message: "Não foi possível atualizar o usuário", errors: errors}}
  end
end
