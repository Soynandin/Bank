defmodule BananaBank.Users.Update do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  def call(%{id: id, current_user: current_user} = params) do
    id = String.to_integer(to_string(id))

    # Buscar o usuário a ser atualizado
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user ->
        # Verifica se o usuário atual tem permissão para editar esse usuário
        cond do
          # Admin pode alterar qualquer usuário, incluindo a si mesmo
          current_user.role == "admin" or current_user.id == user.id ->
            update(user, params)

          # Client ou Agency só pode alterar a si mesmo e não pode mudar seu próprio role para admin
          current_user.id == user.id ->
            if valid_role_change?(params) do  # Removemos current_user aqui
              update(user, params)
            else
              {:error, "Cannot change role to admin"}
            end

          # Client ou Agency não pode alterar outro usuário
          true ->
            {:error, "Unauthorized to update this user"}
        end
    end
  end

  defp valid_role_change?(params) do
    # Verifica se está tentando alterar o role para "admin"
    case Map.get(params, :role) do
      "admin" -> false  # Não pode ser "admin"
      nil -> true  # Caso não esteja tentando alterar o role
      _ -> true  # Pode alterar entre "client" e "agency"
    end
  end

  defp update(user, params) do
    # Aplica o changeset e atualiza o usuário
    user
    |> User.update_changeset(params)
    |> Repo.update()
    |> handle_update_result()
  end

  defp handle_update_result({:ok, user}), do: {:ok, user}

  defp handle_update_result({:error, changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    {:error, Enum.map(errors, fn {field, msg} -> "#{field}: #{msg}" end) |> Enum.join(", ")}
  end

end
