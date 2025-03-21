defmodule BananaBankWeb.Resolvers.UserResolver do
  alias BananaBank.Users
  alias BananaBank.Users.Get
  alias BananaBank.Users.Create
  alias BananaBank.Users.Delete
  alias BananaBank.Users.Update

  def list_users(_parent, args, _resolution) do
    # Pegando os parâmetros de paginação e ordenação
    limit = Map.get(args, :limit, 10) # Definindo o limite padrão como 10
    offset = Map.get(args, :offset, 0) # Definindo o offset padrão como 0
    order_by = Map.get(args, :order_by, "name") # Coluna a ser ordenada
    direction = Map.get(args, :direction, "asc") # Direção de ordenação (asc ou desc)

    {:ok, Users.get_all(limit, offset, order_by, direction)} # Passando os parâmetros para a função
  end

  def get_user(_, %{id: id}, _) do
    case Get.call(id) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, "User not found"}
    end
  end

  def create_user(_parent, args, _resolution) do
    # Chama a função de criação passando os parâmetros
    case Create.call(args) do
      {:ok, user} ->
        # Se a criação for bem-sucedida, retorna o usuário criado
        {:ok, user}

      {:error, changeset} ->
        # Caso contrário, retorna um erro com as mensagens de validação
        {:error, format_errors(changeset)}
    end
  end

  def update_user(_parent, %{id: id} = args, %{context: %{current_user: current_user}}) do
    id = String.to_integer(id)  # Converte o ID para inteiro
    args = Map.put(args, :id, id)
    args = Map.put(args, :current_user, current_user)  # Adiciona o current_user nos argumentos

    case Get.call(id) do
      {:ok, user} ->
        updated_args = Map.merge(Map.from_struct(user), args)

        case authorize_update(current_user, updated_args) do
          :ok ->
            case Update.call(updated_args) do
              {:ok, user} -> {:ok, user}
              {:error, :not_found} -> {:error, "Usuário não encontrado"}
              {:error, msg} -> {:error, msg}
            end

          {:error, msg} -> {:error, msg}
        end

      {:error, :not_found} -> {:error, "Usuário não encontrado"}
    end
  end

 # Função de autorização
defp authorize_update(%{role: "admin"}, %{role: "admin"}), do: :ok
defp authorize_update(%{role: "admin"}, _args), do: :ok

defp authorize_update(%{role: "client"} = current_user, %{id: user_id, role: new_role}) when current_user.id == user_id do
  # Client pode alterar apenas atributos próprios e não pode mudar para "admin"
  if new_role == "admin" do
    {:error, "Unauthorized: Client não pode se promover a admin"}
  else
    :ok
  end
end

defp authorize_update(%{role: "agency"} = current_user, %{id: user_id, role: new_role}) when current_user.id == user_id do
  # Agency pode alterar apenas atributos próprios e não pode mudar para "admin"
  if new_role == "admin" do
    {:error, "Unauthorized: Agency não pode se promover a admin"}
  else
    :ok
  end
end

defp authorize_update(%{id: user_id, role: role}, %{id: user_id, role: new_role}) do
  # Permite alteração de role entre "client" e "agency", mas não permite promover para "admin"
  cond do
    new_role == "admin" -> :ok  # Admin pode promover qualquer usuário para admin
    role in ["client", "agency"] and new_role in ["client", "agency"] -> :ok
    role == new_role -> :ok
    true -> {:error, "Unauthorized"}
  end
end

defp authorize_update(_, _), do: {:error, "Unauthorized"}

  def delete_user(_parent, %{id: id} = args, _resolution) do
    # Converte o ID para inteiro, como fizemos no update
    id = String.to_integer(to_string(id))

    # Atualiza o mapa de argumentos com o ID convertido
    args = Map.put(args, :id, id)

    case Delete.call(args) do
      {:ok, _user} -> {:ok, %{message: "User deleted successfully"}}
      {:error, _reason} -> {:error, %{message: "Failed to delete user"}}
    end
  end

   # Corrigido para aceitar um mapa de erros já extraído do changeset
   def format_errors(errors) do
    Enum.reduce(errors, %{}, fn {field, message}, acc ->
      Map.put(acc, field, message)
    end)
  end
end
