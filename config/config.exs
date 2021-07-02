import Config

import_config "#{Mix.env()}.exs"
if File.exists?("config/#{Mix.env()}.secrets.exs") do
  import_config "#{Mix.env()}.secrets.exs"
end
