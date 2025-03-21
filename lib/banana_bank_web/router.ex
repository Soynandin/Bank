defmodule BananaBankWeb.Router do
  use BananaBankWeb, :router

  # Define um pipeline para a API que aceita apenas JSON
  pipeline :api do
    plug :accepts, ["json"]  # Especifica que a aplicação aceitará apenas o formato JSON
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Jason
  end

  # Define o escopo da API (prefixado com /api) e as rotas dentro deste escopo
  scope "/api", BananaBankWeb do
    pipe_through :api  # Passa o pipeline :api para as rotas abaixo

    get "/", BoasVindas, :index  # Rota inicial (de boas-vindas) para a raiz da API
    resources "/users", UsersController, only: [:create, :update, :delete, :show, :index]
  end

  # Rotas GraphQL fora da pipeline :api
  scope "/" do
    forward "/graphql", Absinthe.Plug, schema: BananaBankWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BananaBankWeb.Schema, interface: :playground
  end

  # Habilita o LiveDashboard no ambiente de desenvolvimento
  if Application.compile_env(:banana_bank, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]  # Adiciona verificações de sessão e proteção contra CSRF

      live_dashboard "/dashboard", metrics: BananaBankWeb.Telemetry
    end
  end
end
