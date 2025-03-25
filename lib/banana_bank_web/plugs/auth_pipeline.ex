defmodule BananaBankWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :banana_bank,
    module: BananaBank.Guardian,
    error_handler: BananaBankWeb.Controllers.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}  # Apenas access tokens
  plug Guardian.Plug.LoadResource
end
