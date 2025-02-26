defmodule BananaBank.Users.Get do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Busca um usuário pelo ID
  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found} # Retorna erro se o usuário não for encontrado
      user -> {:ok, user}         # Retorna o usuário encontrado
    end
  end
end
