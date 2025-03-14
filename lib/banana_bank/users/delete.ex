defmodule BananaBank.Users.Delete do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Exclui um usuário pelo ID
  def call(params) do
    # Converte ID para inteiro
    id = String.to_integer(to_string(params[:id]))

    case Repo.get(User, id) do
      nil -> {:error, :not_found}  # Retorna erro se o usuário não for encontrado
      user -> Repo.delete(user)    # Remove o usuário do banco de dados
    end
  end
end
