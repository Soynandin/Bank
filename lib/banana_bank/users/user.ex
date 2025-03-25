defmodule BananaBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Brcpfcnpj

  @required_params [:first_name, :last_name, :email, :password, :document, :role]
  @required_params_light [:first_name, :last_name, :email, :document, :role]

  @roles ["client", "agency", "admin"]

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
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> validate_document()
    |> add_password_hash()
  end

  # Changeset para atualização de usuário
  def update_changeset(user, params) do
    changeset =
      user
      |> cast(params, @required_params_light)
      |> validate_required(@required_params_light)
      |> validate_format(:email, ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
      |> validate_inclusion(:role, @roles)
      |> unique_constraint(:email)
      |> validate_document()

    # Se o papel do usuário for "admin", permite qualquer alteração
    case user.role do
      "admin" -> changeset
      _ -> restrict_role_change(changeset, user)
    end
  end

  defp add_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Pbkdf2.hash_pwd_salt(password))
  end

  defp add_password_hash(changeset), do: changeset

  defp validate_document(changeset) do
    case get_field(changeset, :document) do
      nil -> changeset
      document ->
        if Brcpfcnpj.cpf_valid?(document) || Brcpfcnpj.cnpj_valid?(document) do
          changeset
        else
          add_error(changeset, :document, "Invalid CPF or CNPJ")
        end
    end
  end

  # Restringe a mudança de role para "admin" para usuários não admin
  defp restrict_role_change(changeset, %__MODULE__{role: "admin"}) do
    changeset
  end

  defp restrict_role_change(changeset, _user) do
    if get_change(changeset, :role) == "admin" do
      add_error(changeset, :role, "Unauthorized role change")
    else
      changeset
    end
  end
end
