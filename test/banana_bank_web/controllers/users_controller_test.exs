defmodule BananaBankWeb.UsersControllerTest do
  use BananaBankWeb.ConnCase

  alias BananaBank.Users
  alias Users.User

  describe "create/2" do
    test "Sucesso em criar o usuário!", %{conn: conn} do # Teste para criação bem-sucedida de usuário
      params = %{
        name: "João",
        cep: "12345678",
        email: "Joao@frutas.com",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params) # Envia requisição POST para criar usuário
        |> json_response(:created) # Espera resposta com status 201 (created)

      assert %{
        "data" => %{"cep" => "12345678", "email" => "Joao@frutas.com", "id" => _id, "name" => "João"},
        "message" => "Usuário criado com sucesso!"
      } = response
    end

    test "Erro em criar o usuário!", %{conn: conn} do # Teste para erro na criação do usuário
      params = %{
        name: nil, # Nome ausente, causará erro de validação
        cep: "12", # CEP inválido
        email: "Joao@frutas.com",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params) # Envia requisição POST inválida
        |> json_response(:bad_request) # Espera status 400 (bad request)

      assert %{
        "errors" => %{"name" => ["can't be blank"]} # Verifica erro específico retornado
      } = response
    end
  end

  describe "delete/2" do
    test "Sucesso em deletar o usuário", %{conn: conn} do # Teste para exclusão bem-sucedida de usuário
      params = %{
        name: "João",
        cep: "12345678",
        email: "Joao@frutas.com",
        password: "123456"
      }

      {:ok, %User{id: id}} = Users.create(params) # Cria usuário antes do teste de exclusão

      response =
        conn
        |> delete(~p"/api/users/#{id}") # Envia requisição DELETE para remover usuário
        |> json_response(:ok) # Espera resposta com status 200 (ok)

      expected_response = %{
        "data" => %{"cep" => "12345678", "email" => "Joao@frutas.com", "id" => id, "name" => "João"},
        "message" => "Usuário apagado com sucesso!"
      }

      assert response == expected_response # Confirma que a resposta é a esperada
    end
  end
end
