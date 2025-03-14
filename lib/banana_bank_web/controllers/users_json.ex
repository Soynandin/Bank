defmodule BananaBankWeb.UsersJSON do
  alias BananaBank.Users.User

  # Retorna a resposta para criação de usuário
  def create(%{user: user}) do
    %{
      message: "Usuário criado com sucesso!",  # Mensagem de sucesso
      data: data(user)                         # Dados do usuário formatados
    }
  end

  # Retorna os dados do usuário para a ação de "get"
  def get(%{user: user}), do: %{data: data(user)}

  # Retorna a resposta para atualização de usuário
  def update(%{user: user}), do: %{message: "Usuário atualizado com sucesso!", data: data(user)}

  # Retorna a resposta para exclusão de usuário
  def delete(%{user: user}), do: %{message: "Usuário apagado com sucesso!", data: data(user)}

  # Formata os dados do usuário para a resposta
  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      document: user.document,
      role: user.role
    }
  end
end
