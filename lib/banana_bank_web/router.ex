defmodule BananaBankWeb.Router do
  use BananaBankWeb, :router

  # Define um pipeline para a API que aceita apenas JSON
  pipeline :api do
    plug :accepts, ["json"]  # Especifica que a aplicação aceitará apenas o formato JSON
  end

  # Define o escopo da API (prefixado com /api) e as rotas dentro deste escopo
  scope "/api", BananaBankWeb do
    pipe_through :api  # Passa o pipeline :api para as rotas abaixo

    get "/", BoasVindas, :index  # Rota inicial (de boas-vindas) para a raiz da API

    # Rotas RESTful para usuários, incluindo operações de create, update, delete, e show
    resources "/users", UsersController, only: [:create, :update, :delete, :show]
  end

  # Habilita o LiveDashboard no ambiente de desenvolvimento
  if Application.compile_env(:banana_bank, :dev_routes) do
    # Importa as rotas do LiveDashboard, útil para métricas e debug
    import Phoenix.LiveDashboard.Router

    # Define uma rota '/dev' para acessar o LiveDashboard com proteção de sessão e CSRF
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]  # Adiciona verificações de sessão e proteção contra CSRF

      # Define a rota para acessar o dashboard de métricas
      live_dashboard "/dashboard", metrics: BananaBankWeb.Telemetry
    end
  end
end
