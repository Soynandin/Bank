defmodule BananaBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  # Campos obrigatórios para criação e atualização completa
  @required_params [:name, :password, :email, :cep]
  # Campos obrigatórios para atualização parcial
  @required_params_light [:name, :email, :cep]

  # Define que apenas os campos id, name, email e cep serão codificados em JSON
  @derive {Jason.Encoder, only: [:id, :name, :email, :cep]}
  schema "users" do # Define que este schema representa a tabela "users"
    field :name, :string
    field :password, :string, virtual: true # Campo virtual (não armazenado no banco)
    field :password_hash, :string
    field :email, :string
    field :cep, :string

    timestamps() # Adiciona campos inserted_at e updated_at
  end

  # Changeset para criação de usuário
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)      # Filtra e converte os parâmetros permitidos
    |> validate_required(@required_params) # Garante que os campos obrigatórios estão presentes
    |> validate_format(:email, ~r/@/) # Valida se o email possui formato correto
    |> add_password_hash() # Adiciona hash da senha
  end

  # Changeset para atualização de usuário
  def changeset(user, params) do
    user
    |> cast(params, @required_params)      # Filtra e converte os parâmetros permitidos
    |> validate_required(@required_params_light) # Valida os campos obrigatórios na atualização
    |> validate_format(:email, ~r/@/) # Valida formato do email
  end

  # Gera o hash da senha antes de salvar o usuário, caso a senha esteja presente e válida
  defp add_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Pbkdf2.hash_pwd_salt(password)) # Gera o hash da senha
  end

  # Se não houver senha, retorna o changeset sem alterações
  defp add_password_hash(changeset), do: changeset
end
