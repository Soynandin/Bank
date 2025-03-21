defmodule BananaBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Brcpfcnpj

  # Campos obrigatórios para criação e atualização completa
  @required_params [:first_name, :last_name, :email, :password, :document, :role]

  # Campos obrigatórios para atualização parcial
  @required_params_light [:first_name, :last_name, :email, :document]

  @valid_roles ["client", "agency", "admin"]

  # Define que apenas os campos id, first_name, last_name, email, document, role serão codificados em JSON
  @derive {Jason.Encoder, only: [:id, :first_name, :last_name, :email, :document, :role]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :document, :string
    field :role, :string
    timestamps()
  end

  def create_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
    |> validate_inclusion(:role, @valid_roles)
    |> validate_document()
    |> unique_constraint(:email, message: "Este email já está em uso")
    |> add_password_hash()
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @required_params_light ++ [:role])
    |> validate_required(@required_params_light)
    |> validate_format(:email, ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
    |> validate_inclusion(:role, @valid_roles)
    |> validate_document()
    |> unique_constraint(:email)
    |> validate_role_change(user)
  end


  # Validação para impedir promoções não autorizadas
  defp validate_role_change(changeset, %__MODULE__{role: current_role}) do
    new_role = get_change(changeset, :role)

    cond do
      current_role in ["client", "agency"] and new_role == "admin" ->
        add_error(changeset, :role, "Unauthorized: Only admins can become 'admin'.")

      true ->
        changeset
    end
  end

  # Gera o hash da senha antes de salvar o usuário, caso a senha esteja presente e válida
  defp add_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Pbkdf2.hash_pwd_salt(password))
  end

  defp add_password_hash(changeset), do: changeset

  defp validate_document(changeset) do
    document = get_field(changeset, :document)

    if document && !Brcpfcnpj.cpf_valid?(document) && !Brcpfcnpj.cnpj_valid?(document) do
      add_error(changeset, :document, "Documento inválido. Insira um CPF ou CNPJ válido.")
    else
      changeset
    end
  end


end
