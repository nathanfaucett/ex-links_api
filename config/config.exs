# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :links_api,
  ecto_repos: [LinksApi.Repo]

# Configures the endpoint
config :links_api, LinksApi.Web.Endpoint,
  url: [host: "api.links.hackertarian.com"],
  check_origin: ["//*.hackertarian.com"],
  secret_key_base: "S1JPItKfCccin85OAFMrzagMACgVUO6DJmLlbIcN+qAOaYatwrZkZrBVLU2VMWQN",
  render_errors: [view: LinksApi.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: LinksApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :links_api, LinksApi.Web.OAuth2.Github,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI")

config :links_api, LinksApi.Web.OAuth2.Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
