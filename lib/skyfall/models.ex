defmodule Skyfall.Models do
  @enforce_keys [:name, :credentials]
  defstruct [:name, :credentials]
  @type t :: %__MODULE__{name: String.t(), credentials: map()}

  def models() do
    [
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-4",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo1",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo2",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo3",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo4",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo5",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo6",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo7",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo8",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo9",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo10",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo11",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo12",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo13",
        api_key: System.get_env("OPENAI_API_KEY")
      },
      %Skyfall.Models.Openai{
        model: "gpt-3.5-turbo14",
        api_key: System.get_env("OPENAI_API_KEY")
      }
    ]
  end
end
