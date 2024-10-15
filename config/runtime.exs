import Config

with {:ok, content} <- File.read(".env") do
  content
  |> String.split(~r/\n/)
  |> Enum.reject(&(String.trim(&1) == ""))
  |> Enum.each(fn line ->
    [key, value] = String.split(line, "=", parts: 2)
    System.put_env(key, value)
  end)
end

if System.get_env("PHX_SERVER") do
  config :skyfall, SkyfallWeb.Endpoint, server: true
end

config :skyfall,
  hf_token: System.fetch_env!("HF_TOKEN"),
  max_new_tokens: System.get_env("MAX_NEW_TOKENS", "256") |> String.to_integer(),
  sequence_length: System.get_env("SEQUENCE_LENGTH", "1028") |> String.to_integer(),
  batch_size: System.get_env("BATCH_SIZE", "1") |> String.to_integer()

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :skyfall, Skyfall.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :skyfall, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :skyfall, SkyfallWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base
end
