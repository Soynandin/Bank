defmodule BananaBankWeb.Resolvers.AuthResolver do
  alias BananaBank.Auth
  alias BananaBank.Guardian

  def login(_parent, %{email: email, password: password}, _resolution) do
    case Auth.authenticate(%{email: email, password: password}) do
      {:ok, %{token: access_token, refresh_token: refresh_token}} ->
        {:ok, %{token: access_token, refresh_token: refresh_token}}

      {:error, reason} -> {:error, reason}
    end
  end

  def refresh_token(_parent, %{refresh_token: refresh_token}, _resolution) do
    case Auth.refresh_access_token(refresh_token) do
      {:ok, tokens} -> {:ok, tokens}
      {:error, reason} -> {:error, reason}
    end
  end

  def logout(_parent, _args, %{context: context}) do
    case Map.get(context, :token) do
      nil -> {:error, "No token provided"}
      refresh_token ->
        case Guardian.revoke(refresh_token) do
          {:ok, _claims} -> {:ok, %{message: "Logged out successfully"}}
          {:error, reason} -> {:error, "Failed to revoke token: #{reason}"}
        end
    end
  end

end
