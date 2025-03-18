defmodule BananaBankWeb.Resolvers.AuthResolver do
  alias BananaBank.Guardian

  def login(_parent, %{email: email, password: password}, _resolution) do
    case Guardian.authenticate(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{})
        {:ok, %{token: token}}

      {:error, reason} -> {:error, reason}
    end
  end

  def logout(_parent, _args, %{context: %{token: token}}) do
    case Guardian.revoke(token) do
      {:ok, _claims} ->
        {:ok, %{message: "Logout realizado com sucesso"}}
      {:error, _reason} ->
        {:error, "Erro ao realizar logout"}
    end
  end
end
