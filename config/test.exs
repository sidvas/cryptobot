import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cryptobot, CryptobotWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "R1jRrQLW4B/mXGfOlW4vgSlHrNohEP6icZsE2Q+pz26MrMVUYHR3ZS1pmR8iJOmn",
  server: false

# In test we don't send emails.
config :cryptobot, Cryptobot.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
