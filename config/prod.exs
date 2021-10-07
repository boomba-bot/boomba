import Config

config :boomba,
  token: System.get_env("DISCORD_TOKEN"),
  se_token: System.get_env("SE_TOKEN")
