defmodule BananaBankWeb.Schema do
  use Absinthe.Schema

  alias BananaBankWeb.Resolvers.{UserResolver, AuthResolver, TravelPackageResolver}

  import_types Absinthe.Type.Custom

  # ========== QUERIES ==========
  query do
    field :users, list_of(:user) do
      arg :limit, :integer, default_value: 10
      arg :offset, :integer, default_value: 0
      arg :order_by, :string, default_value: "name"
      arg :direction, :string, default_value: "asc"
      resolve(&UserResolver.list_users/3)
    end

    field :user, :user do
      arg :id, non_null(:id)
      resolve(&UserResolver.get_user/3)
    end

    field :me, :user do
      middleware BananaBankWeb.Middleware.Authenticate
      resolve fn _, _, %{context: %{current_user: user}} ->
        IO.inspect(user, label: "Usuário autenticado")
        {:ok, user}
      end
    end

    field :travel_packages, list_of(:travel_package) do
      arg :limit, :integer
      arg :offset, :integer
      arg :order_by, :string
      arg :direction, :string
      resolve(&TravelPackageResolver.list_packages/3)
    end

    field :travel_package, :travel_package do
      arg :id, non_null(:id)
      resolve(&TravelPackageResolver.get_package/3)
    end
  end

  # ========== MUTATIONS ==========
  mutation do
    field :create_user, :user do
      arg :first_name, non_null(:string)
      arg :last_name, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :document, non_null(:string)
      arg :role, non_null(:string)
      resolve(&UserResolver.create_user/3)
    end

    field :update_user, :user do
      middleware BananaBankWeb.Middleware.Authenticate
      arg :id, non_null(:id)
      arg :first_name, :string
      arg :last_name, :string
      arg :email, :string
      arg :document, :string
      arg :role, :string
      resolve(&UserResolver.update_user/3)
    end

    field :delete_user, :delete_user_response do
      arg :id, non_null(:id)
      resolve(&UserResolver.delete_user/3)
    end

    field :login, :auth_payload do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve(&AuthResolver.login/3)
    end

    field :refresh_token, :auth_payload do
      arg :refresh_token, non_null(:string)
      resolve(&AuthResolver.refresh_token/3)
    end

    field :logout, :message do
      middleware BananaBankWeb.Middleware.Authenticate
      resolve(&AuthResolver.logout/3)
    end

    field :create_travel_package, :travel_package do
      middleware BananaBankWeb.Middleware.Authenticate
      arg :title, non_null(:string)
      arg :destination, non_null(:string)
      arg :price, non_null(:float)
      arg :availability_start_date, non_null(:date)
      arg :availability_end_date, non_null(:date)
      arg :description, :string
      arg :cancellation_policy, non_null(:string)
      arg :total_slots, non_null(:integer)
      arg :remaining_slots, non_null(:integer)
      arg :status, non_null(:string)
      resolve(&TravelPackageResolver.create_package/3)
    end

    field :update_travel_package, :travel_package do
      middleware BananaBankWeb.Middleware.Authenticate
      arg :id, non_null(:id)
      arg :title, :string
      arg :price, :float
      # Adicione mais campos se desejar atualizá-los
      resolve(&TravelPackageResolver.update_package/3)
    end

    field :delete_travel_package, :message do
      middleware BananaBankWeb.Middleware.Authenticate
      arg :id, non_null(:id)
      resolve(&TravelPackageResolver.delete_package/3)
    end
  end

  # ========== OBJECT TYPES ==========
  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :document, :string
    field :role, :string
  end

  object :travel_package do
    field :id, :id
    field :title, :string
    field :destination, :string
    field :price, :float
    field :availability_start_date, :date
    field :availability_end_date, :date
    field :description, :string
    field :cancellation_policy, :string
    field :total_slots, :integer
    field :remaining_slots, :integer
    field :status, :string
    field :agency_id, :id
  end

  object :auth_payload do
    field :access_token, :string
    field :refresh_token, :string
    field :user, :user
  end

  object :message do
    field :message, :string
  end

  object :delete_user_response do
    field :message, :string
  end
end
