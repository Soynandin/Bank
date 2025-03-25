defmodule BananaBank.Auth do
  alias BananaBank.{Users, Guardian}
  alias Pbkdf2

  def authenticate(%{email: email, password: password}) do
    with {:ok, user} <- get_user_by_email(email),
         true <- Pbkdf2.verify_pass(password, user.password_hash) do
      Guardian.encode_and_sign(user)
    else
      {:error, :not_found} -> {:error, "User not found"}
      _ -> {:error, "Invalid credentials"}
    end
  end

  defp get_user_by_email(email) do
    Users.get_by_email(email)
  end
end
