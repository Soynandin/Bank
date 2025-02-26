defmodule BananaBank.Users.Create do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Cria um novo usuário no banco de dados
  def call(params) do
    params
    |> User.changeset()  # Aplica as validações e formatações do changeset
    |> Repo.insert()     # Insere o usuário no banco
  end
end
