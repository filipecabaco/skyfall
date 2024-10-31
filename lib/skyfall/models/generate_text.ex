defprotocol Skyfall.Models.GenerateText do
  @callback generate(messages :: list(String.t()), t) :: {:ok, list(String.t())} | {:error, any()}
  @spec generate(t, messages :: list(String.t())) :: {:ok, list(String.t())} | {:error, any()}
  def generate(model, messages)

  @spec chat_key(t) :: Atom.t()
  def chat_key(model)

  @spec name(t) :: String.t()
  def name(model)
end
