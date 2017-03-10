defmodule LinksApi.Mixfile do
  use Mix.Project

  def project do
    [app: :links_api,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {LinksApi, []},
      applications: [
       :phoenix, :phoenix_pubsub,
       :cowboy, :logger,
       :gettext,
       :phoenix_ecto, :postgrex,
       :cors_plug,
       :comeonin,
       :secure_random,
       :bamboo_smtp,
       :bamboo,
       :edeliver]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:postgrex, ">= 0.13.0"},
     {:gettext, "~> 0.13"},
     {:comeonin, "~> 3.0"},
     {:secure_random, "~> 0.5"},
     {:cors_plug, "~> 1.2"},
     {:bamboo, "~> 0.8"},
     {:bamboo_smtp, "~> 1.2"},
     {:cowboy, "~> 1.1"},
     {:poison, "~> 2.0"},
     {:edeliver, "~> 1.4.2"},
     {:distillery, ">= 0.8.0", warn_missing: false}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.core": ["ecto.create", "ecto.migrate"],
     "ecto.setup": ["ecto.core", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "setup": ["deps.get", "ecto.reset"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
