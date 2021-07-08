# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blog_api,
  ecto_repos: [BlogApi.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :blog_api, BlogApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6HFxJWSYbU6nC/RsojMxVw1YRKSB2orruuE1nN/KFwj8jyRkq1wT+IK3teJvJ7Jl",
  render_errors: [view: BlogApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BlogApi.PubSub,
  live_view: [signing_salt: "7xbypcsB"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :blog_api, BlogApi.Accounts.Guardian,
       issuer: "blog_api",
       secret_key: "xz8foWW+WdqhceOFqYiARhK5cU5ibmVy6BVkXmvvoHGj/qB3NJrHRlntuOod+nGZ"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
