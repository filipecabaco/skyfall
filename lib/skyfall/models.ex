defmodule Skyfall.Models do
  defstruct [:name, :repository, :auth?, :tensor_type]

  def models(),
    do: [
      %__MODULE__{name: :gemma, repository: "google/gemma-2b", auth?: true, tensor_type: :bf16},
      %__MODULE__{name: :phi, repository: "microsoft/Phi-3.5-mini-instruct", auth?: false, tensor_type: :bf16}
      # %__MODULE__{name: :nemo, repository: "mistralai/Mistral-Nemo-Instruct-2407", auth?: true, tensor_type: :bf16}
    ]
end
