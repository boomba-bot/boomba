import Config

config :boomba,
  token: System.get_env("DISCORD_TOKEN"),
  se_token: System.get_env("SE_TOKEN"),
  twitter: System.get_env("TWITTER_BEARER")
