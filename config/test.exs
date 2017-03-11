use Mix.Config


config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :links_api, LinksApi.Endpoint,
  http: [port: 3001],
  check_origin: ["//*.hackertarian.com"],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :links_api, LinksApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "links_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
