defmodule BananaBank.Guardian do
  use Guardian, otp_app: :banana_bank

  alias BananaBank.Users

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  def resource_from_claims(%{"sub" => id}) do
    case Users.get(id) do
      {:ok, user} -> {:ok, user}
      _ -> {:error, :not_found}
    end
  end

  def authenticate(email, password) when is_binary(password) and byte_size(password) > 0 do
    case Users.get_by_email(email) do
      {:ok, user} ->
        if Pbkdf2.verify_pass(password, user.password_hash), do: {:ok, user}, else: {:error, "Incorrect password"}
      _ -> {:error, "User not found"}
    end
  end


  def authenticate(_email, _password), do: {:error, "Invalid credentials"}
end
