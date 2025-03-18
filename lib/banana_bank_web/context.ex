defmodule BananaBankWeb.Context do
  @behaviour Plug

  import Plug.Conn
  alias BananaBank.Guardian

  def init(opts), do: opts

  def call(conn, _) do
    IO.inspect(get_req_header(conn, "authorization"), label: "🔍 Header Authorization")

    case get_current_user(conn) do
      {:ok, user, token} ->
        context = %{current_user: user, token: token}
        put_private(conn, :absinthe, %{context: context})

      _ ->
        put_private(conn, :absinthe, %{context: %{}})
    end
  end

  defp get_current_user(conn) do
    with {:ok, token} <- extract_token(conn),
         {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      {:ok, user, token} # ✅ Agora retornamos o token junto com o usuário
    else
      error ->
        IO.inspect(error, label: "⚠️ Erro ao buscar usuário")
        :error
    end
  end

  defp extract_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> :error
    end
  end
end
