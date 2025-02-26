defmodule BananaBankWeb.FallbackController do
  use BananaBankWeb, :controller

  # Trata erro 'not_found', retornando status 400 (bad request)
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:bad_request)  # Define o código de status HTTP como 400
    |> put_view(json: BananaBankWeb.ErrorJSON)  # Define a view de erro
    |> render(:error, status: :not_found)  # Renderiza o template de erro com a mensagem de 'não encontrado'
  end

  # Trata erros de changeset (validação de dados), retornando status 400
  def call(conn, {:error, changeset}) do
    conn
    |> put_status(:bad_request)  # Define o código de status HTTP como 400
    |> put_view(json: BananaBankWeb.ErrorJSON)  # Define a view de erro
    |> render(:error, changeset: changeset)  # Renderiza o template de erro com os erros do changeset
  end
end
