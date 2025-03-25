import Config

config :banana_bank,
  ecto_repos: [BananaBank.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :banana_bank, BananaBankWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BananaBankWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BananaBank.PubSub,
  live_view: [signing_salt: "JKpQ4w/2"]

# Configuração do Guardian para autenticação
config :banana_bank, BananaBank.Guardian,
  issuer: "banana_bank",
  secret_key: System.get_env("GUARDIAN_SECRET") || "jhjRjHq6VlFOxraBn3deWqy+icMlF19vwsMle02m2mCf0wq2+1hdMfVSsLzlXTWV"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
