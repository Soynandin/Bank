defmodule BananaBank.Users.Delete do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Exclui um usuário pelo ID
  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}  # Retorna erro se o usuário não for encontrado
      user -> Repo.delete(user)    # Remove o usuário do banco de dados
    end
  end
end
