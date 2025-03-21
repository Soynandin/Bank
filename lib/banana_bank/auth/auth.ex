defmodule BananaBank.Auth do
  alias BananaBank.{Users, Guardian}
  alias Pbkdf2

  def authenticate(%{email: email, password: password}) do
    with {:ok, user} <- Users.get_by_email(email),
      true <- Pbkdf2.verify_pass(password, user.password_hash),
      {:ok, access_token, _claims} <- Guardian.encode_and_sign(user, %{}, ttl: {15, :minutes}),
      {:ok, refresh_token, _} <- Guardian.encode_and_sign(user, %{}, ttl: {7, :days}) do
    {:ok, %{token: access_token, refresh_token: refresh_token}}
    else
      {:error, :not_found} -> {:error, "User not found"}
      false -> {:error, "Invalid credentials"}
      _ -> {:error, "Authentication failed"}
    end
  end

  def refresh_access_token(refresh_token) do
    case Guardian.decode_and_verify(refresh_token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            {:ok, new_access_token, _} = Guardian.encode_and_sign(user, %{}, ttl: {15, :minutes})
            {:ok, %{token: new_access_token, refresh_token: refresh_token}}

          {:error, _} -> {:error, "Invalid refresh token"}
        end

      {:error, _} -> {:error, "Invalid refresh token"}
    end
  end

  def revoke_user_refresh_tokens(_user_id), do: :ok

end
