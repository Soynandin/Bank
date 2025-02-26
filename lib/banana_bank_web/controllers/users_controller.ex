defmodule BananaBankWeb.UsersController do
  use BananaBankWeb, :controller

  alias BananaBank.Users
  alias Users.User

  # Define um fallback para erros, transformando respostas inesperadas em erros HTTP apropriados
  action_fallback BananaBankWeb.FallbackController

  # Criação de usuário
  def create(conn, params) do
    with {:ok, %User{} = user} <- Users.create(params) do
      conn
      |> put_status(:created) # Retorna status 201 (Created)
      |> render(:create, user: user)
    end
  end

  # Busca de usuário por ID
  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.get(id) do
      conn
      |> put_status(:ok) # Retorna status 200 (OK)
      |> render(:get, user: user)
    end
  end

  # Atualização de usuário
  def update(conn, params) do
    with {:ok, %User{} = user} <- Users.update(params) do
      conn
      |> put_status(:ok) # Retorna status 200 (OK)
      |> render(:update, user: user)
    end
  end

  # Exclusão de usuário
  def delete(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.delete(id) do
      conn
      |> put_status(:ok) # Retorna status 200 (OK)
      |> render(:delete, user: user)
    end
  end
end
