defmodule BananaBankWeb.Resolvers.AuthResolver do
  alias BananaBank.Guardian

  def login(_parent, %{email: email, password: password}, _resolution) do
    case Guardian.authenticate(email, password) do
      {:ok, user} ->
        {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute})
        {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

        {:ok, %{
          access_token: access_token,
          refresh_token: refresh_token,
          user: %{id: user.id, email: user.email, role: user.role}
        }}

      {:error, reason} -> {:error, reason}
    end
  end

  def refresh_token(_parent, %{refresh_token: refresh_token}, _resolution) do
    with {:ok, claims} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}),
         {:ok, user} <- Guardian.resource_from_claims(claims),
         {:ok, new_access_token, _} <- Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute}) do
      {:ok, %{access_token: new_access_token}}
    else
      _ -> {:error, "Invalid refresh token"}
    end
  end

  def logout(_parent, _args, %{context: %{token: token}}) do
    case Guardian.revoke(token) do
      {:ok, _claims} -> {:ok, %{message: "Logout realizado com sucesso"}}
      {:error, reason} -> {:error, "Erro ao realizar logout: #{inspect(reason)}"}
    end
  end
end
