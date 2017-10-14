# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :gitmetrics,
  ecto_repos: [Gitmetrics.Repo]

# Configures the endpoint
config :gitmetrics, GitmetricsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "W3q3u3k6lwvkC1mRXZeZHpJB4IawvCxTxTUTmLDpCEW+ZKfebXn/GWhKz5tzNKZ3",
  render_errors: [view: GitmetricsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gitmetrics.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

  config :gitmetrics, Gitmetrics.Guardian,
         issuer: "gitmetrics",
         secret_key: "W3q3u3k6lwvkC1mRXZeZHpJB4IawvCxTxTUTmLDpCEW+ZKfebXn/GWhKz5tzNKZ3"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
