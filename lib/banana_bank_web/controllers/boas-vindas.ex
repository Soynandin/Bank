defmodule BananaBankWeb.BoasVindas do
  use BananaBankWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Bem vindo ao Banana Bank!"})
  end
end
