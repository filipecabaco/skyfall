defmodule Skyfall.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Nx.global_default_backend({EXLA.Backend, client: :host})
    hf_token = Application.get_env(:skyfall, :hf_token)
    max_new_tokens = Application.get_env(:skyfall, :max_new_tokens)
    sequence_length = Application.get_env(:skyfall, :sequence_length)
    batch_size = Application.get_env(:skyfall, :batch_size)

    serving_child_specs =
      for %{name: name, repository: repository, auth?: auth?, tensor_type: tensor_type} <- Skyfall.Models.models() do
        repository = if auth?, do: {:hf, repository, auth_token: hf_token}, else: {:hf, repository}
        {:ok, model_info} = Bumblebee.load_model(repository, type: tensor_type)
        {:ok, tokenizer} = Bumblebee.load_tokenizer(repository)
        {:ok, generation_config} = Bumblebee.load_generation_config(repository)

        generation_config =
          Bumblebee.configure(generation_config,
            max_new_tokens: max_new_tokens,
            strategy: %{type: :multinomial_sampling, top_p: 0.6}
          )

        serving =
          Bumblebee.Text.generation(model_info, tokenizer, generation_config,
            compile: [batch_size: batch_size, sequence_length: sequence_length],
            stream: true,
            defn_options: [compiler: EXLA]
          )

        {Nx.Serving, name: name, serving: serving}
      end

    children =
      serving_child_specs ++
        [
          SkyfallWeb.Telemetry,
          Skyfall.Repo,
          {Phoenix.PubSub, name: Skyfall.PubSub},
          SkyfallWeb.Endpoint
        ]

    opts = [strategy: :one_for_one, name: Skyfall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkyfallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
