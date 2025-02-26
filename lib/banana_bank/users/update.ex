defmodule BananaBank.Users.Update do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Atualiza um usuário pelo ID
  def call(%{"id" => id} = params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}  # Retorna erro se o usuário não for encontrado
      user -> update(user, params) # Aplica a atualização
    end
  end

  # Aplica as mudanças e atualiza o usuário no banco
  defp update(user, params) do
    user
    |> User.changeset(params) # Valida e aplica as mudanças
    |> Repo.update()          # Atualiza no banco de dados
  end
end
