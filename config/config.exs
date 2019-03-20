# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :rhyme_thyme, RhymeThymeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "67EWRVH/sT3A+M8eewHJQG7G2Z46DglsmVH0BZZtHTS6N7uUMwdbZeSV9VuR+aj1",
  render_errors: [view: RhymeThymeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RhymeThyme.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [ signing_salt: "QccfcwiFGG1cz5vA7ZTIBzKLe0+2Ogjr" ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
