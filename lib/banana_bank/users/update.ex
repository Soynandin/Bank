defmodule BananaBank.Users.Update do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  def call(%{id: id, current_user: %{id: current_id, role: current_role}} = params) do
    id = String.to_integer(to_string(id))

    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user ->
        # Verifica se o admin está tentando atualizar qualquer usuário
        if current_role == "admin" do
          # Admin pode atualizar qualquer coisa, incluindo o role
          updated_params = params
          update(user, updated_params)
        else
          # Se não for admin, verifica se o usuário está tentando atualizar seu próprio perfil
          if user.id == current_id do
            # Se o cliente ou agência está atualizando a si mesmo, ele não pode alterar o role para "admin"
            updated_params =
              case {user.role, params.role} do
                {"client", "admin"} -> Map.put(params, :role, user.role) # Impede que client vire admin
                {"agency", "admin"} -> Map.put(params, :role, user.role) # Impede que agency vire admin
                _ -> params # Permite qualquer outra alteração (exceto para role)
              end

            update(user, updated_params)
          else
            {:error, "Você não tem permissão para atualizar este usuário"}
          end
        end
    end
  end

  defp update(user, params) do
    # Atualiza o usuário com os parâmetros fornecidos
    user
    |> User.update_changeset(params)
    |> Repo.update()
    |> handle_update_result()
  end

  defp handle_update_result({:ok, user}), do: {:ok, user}

  defp handle_update_result({:error, changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    {:error, %{message: "Não foi possível atualizar o usuário", errors: errors}}
  end
end
