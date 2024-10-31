defmodule Skyfall.Models.Openai do
  defstruct [:api_key, :model, name: "OpenAI"]

  defimpl Skyfall.Models.GenerateText, for: Skyfall.Models.Openai do
    @url "https://api.openai.com/v1/chat/completions"
    alias Skyfall.Models.Openai

    def generate(%Openai{} = model, messages) do
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{model.api_key}"}
      ]

      body = Jason.encode!(%{"model" => model.name, "messages" => messages})

      {:ok, response} = Req.post(@url, headers: headers, body: body)
      response.body
    end

    def chat_key(%Openai{model: model}), do: :"openai_#{model}"
    def name(%Openai{name: name, model: model}), do: "#{name} (#{model})"
  end
end
