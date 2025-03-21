defmodule BananaBankWeb.Schema do
  use Absinthe.Schema

  alias BananaBankWeb.Resolvers.UserResolver

  query do
    field :users, list_of(:user) do
      arg :limit, :integer, default_value: 10  # Limite de resultados
      arg :offset, :integer, default_value: 0  # Offset de resultados
      arg :order_by, :string, default_value: "name"  # Coluna para ordenação
      arg :direction, :string, default_value: "asc"  # Direção de ordenação
      resolve(&UserResolver.list_users/3)
    end

    field :user, :user do
      arg :id, non_null(:id)
      resolve(&UserResolver.get_user/3)
    end
  end

  mutation do
    field :create_user, :user do
      arg :first_name, non_null(:string)  # Alteração para first_name
      arg :last_name, non_null(:string)   # Alteração para last_name
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :document, non_null(:string)    # Alteração para document (CPF/CNPJ)
      arg :role, non_null(:string)        # Alteração para role (client ou agency)
      resolve(&UserResolver.create_user/3)
    end

    field :update_user, :user do
      arg :id, non_null(:id)
      arg :first_name, :string  # Alteração para first_name
      arg :last_name, :string   # Alteração para last_name
      arg :email, :string
      arg :document, :string    # Alteração para document (CPF/CNPJ)
      arg :role, :string        # Alteração para role (client ou agency)
      resolve(&UserResolver.update_user/3)
    end

    field :delete_user, :delete_user_response do
      arg :id, non_null(:id)
      resolve(&UserResolver.delete_user/3)
    end
  end

  object :user do
    field :id, :id
    field :first_name, :string  # Alteração para first_name
    field :last_name, :string   # Alteração para last_name
    field :email, :string
    field :document, :string    # Alteração para document (CPF/CNPJ)
    field :role, :string        # Alteração para role (client ou agency)
  end

  object :message do
    field :message, :string
  end

  object :delete_user_response do
    field :message, :string
  end
end
