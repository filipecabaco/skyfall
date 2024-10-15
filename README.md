# Skyfall

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

The intent is to showcase what would be the result in different LLMs so you can test each one of the models simultaneously.

Currently the models it runs are:
* google/gemma-2b
* microsoft/Phi-3.5-mini-instruct
* mistralai/Mistral-Nemo-Instruct-2407

For Mistral and Google models be aware that you need a Hugging Face token and to accept their terms and conditions. More details here: [https://huggingface.co/docs/hub/en/security-tokens](https://huggingface.co/docs/hub/en/security-tokens)