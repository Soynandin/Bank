defmodule BananaBankWeb.Middleware.Authenticate do
  def call(resolution, _config) do
    IO.inspect(resolution.context, label: "Contexto do usuário no Middleware")

    case resolution.context do
      %{current_user: _user} -> resolution
      _ -> Absinthe.Resolution.put_result(resolution, {:error, "Unauthorized"})
    end
  end
end
