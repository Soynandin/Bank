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
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, format_errors(changeset)}
    end
  end

  def update_user(_parent, %{id: id} = args, %{context: %{current_user: current_user}}) do
    IO.inspect(current_user, label: "Current User") # Debug

    id =
      case Integer.parse(to_string(id)) do
        {int_id, ""} -> int_id
        _ -> {:error, "Invalid ID format"}
      end

    case id do
      {:error, msg} -> {:error, msg}
      id when is_integer(id) ->
        params = Map.put(args, :current_user, current_user)

        case Update.call(params) do
          {:ok, user} -> {:ok, user}
          {:error, :not_found} -> {:error, "User not found"}
          {:error, msg} -> {:error, msg}
        end
    end
  end


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
