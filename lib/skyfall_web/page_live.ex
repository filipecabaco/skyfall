defmodule SkyfallWeb.PageLive do
  use SkyfallWeb, :live_view
  require Logger
  alias Skyfall.Models
  alias Skyfall.Models.GenerateText
  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :models, Models.models())
    socket = Enum.reduce(Models.models(), socket, &stream(&2, GenerateText.chat_key(&1), []))
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full p-3 gap-3 flex flex-col">
      <form class="grow-0 w-full flex flex-col gap-3" phx-submit="enter">
        <input name="text" phx-debounce="500" class="w-full rounded-xl p-3 text-gray-800" placeholder="Type a message..." />
        <div
          id="drawer"
          class="bg-gray-200 p-3 rounded-xl cursor-pointer items-center justify-between flex flex-col gap-3 select-none shadow hover:bg-gray-300"
          phx-click={JS.toggle(to: "#drawer_content")}
        >
          <div>Advanced</div>
          <div id="drawer_content" class="hidden bg-white w-full rounded-xl p-3">Extra</div>
        </div>
      </form>
      <div class="grow w-full flex flex-wrap gap-3 justify-between overflow-auto">
        <div :for={model <- @models} class="flex flex-col h-[40rem] bg-white rounded-xl w-full max-w-[49%] shadow-sm">
          <div class="grow-0 bg-slate-200 rounded-lg p-3 shadow-sm"><%= GenerateText.name(model) %></div>
          <div
            class="p-1 pt-4 overflow-auto flex flex-col"
            phx-update="stream"
            id={"chat_#{GenerateText.chat_key(model)}"}
            phx-hook="AutoScroll"
          >
            <div
              :for={{id, %{content: content, model: model}} <- Map.get(@streams, GenerateText.chat_key(model))}
              id={id}
              class={"bubble #{content == :loading && "loading"} #{is_nil(model) && "user"}"}
            >
              <%= if content == :loading, do: "#{GenerateText.name(model)} is thinking", else: content %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("enter", %{"text" => text}, socket) do
    socket =
      Enum.reduce(
        Models.models(),
        socket,
        fn model, socket ->
          model_chat_id = Ecto.UUID.generate()

          Task.async(fn ->
            Process.sleep(2000)
            {:done, model_chat_id, model, Faker.Lorem.paragraph(1..100)}
          end)

          chat_key = GenerateText.chat_key(model)

          socket
          |> stream_insert(chat_key, %{id: Ecto.UUID.generate(), model: nil, content: text})
          |> stream_insert(chat_key, %{id: model_chat_id, model: model, content: :loading})
        end
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({_, {:done, id, model, content}}, socket) do
    Logger.info("Model #{GenerateText.name(model)} finished processing")
    socket = stream_insert(socket, GenerateText.chat_key(model), %{id: id, model: model, content: content})
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
