defmodule BananaBank.Users.Create do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  # Cria um novo usuário no banco de dados
  def call(params) when is_map(params) do
    %User{}
    |> User.create_changeset(params)  # Aplica as validações e formatações do changeset
    |> Repo.insert()                  # Insere o usuário no banco
    |> handle_insert_result()          # Trata o resultado da inserção
  end

  def call(_), do: {:error, "Invalid parameters"}  # Caso `params` não seja um mapa, retorna erro

  # Processa o resultado da inserção no banco
  defp handle_insert_result({:ok, user}), do: {:ok, user}

  defp handle_insert_result({:error, changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    {:error, %{message: "Não foi possível criar o usuário", errors: errors}}
  end

end
