defmodule BananaBankWeb.Middleware.ExtractRefreshToken do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    refresh_token =
      resolution.arguments
      |> Map.get(:refresh_token, nil)

    if refresh_token do
      new_context = Map.put(resolution.context, :refresh_token, refresh_token)
      %{resolution | context: new_context}
    else
      resolution
    end
  end
end
