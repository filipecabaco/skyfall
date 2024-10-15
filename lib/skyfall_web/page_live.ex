defmodule SkyfallWeb.PageLive do
  use SkyfallWeb, :live_view
  require Logger
  alias Skyfall.Models

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:chats, [])
      |> assign(:model, nil)
      |> assign(:loading, 0)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen bg-gray-100 flex items-center justify-between p-5 gap-3">
      <div class="grow flex flex-col bg-white rounded-xl border-2 h-full w-full">
        <div class="grow h-full p-2">
          <div :for={{id, %{model: model, content: content}} <- @streams.chats} id={id} class="flex flex-col">
            <div
              :if={model}
              class={"bg-green-100 w-1/2 rounded-xl p-2 mb-1 text-gray-800 #{content == :loading && "animate-pulse bg-green-300"} "}
            >
              <div :if={content == :loading}><%= model %> is thinking...</div>
              <div :if={content != :loading}><%= model %>: <%= content %></div>
            </div>
            <div :if={!model} class="bg-blue-100 w-1/2 rounded-xl p-2 mb-1 text-gray-800 self-end">
              <%= content %>
            </div>
          </div>
        </div>
        <div class="grow-0 rounded-b-xl bg-gray-100 h-[5rem] p-2 flex items-center drop-shadow">
          <form phx-submit="enter" class="w-full">
            <input disabled={@loading > 0} type="text" name="text" id="text" class="w-full rounded-xl drop-shadow border-0" />
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("enter", %{"text" => text}, socket) do
    socket =
      socket
      |> assign(:loading, Enum.count(Models.models()))
      |> stream_insert(:chats, %{id: Ecto.UUID.generate(), model: nil, content: text})

    socket =
      Enum.reduce(Models.models(), socket, fn %{name: name}, socket ->
        id = Ecto.UUID.generate()
        Task.async(fn -> {id, name, Nx.Serving.batched_run({:local, name}, text)} end)
        stream_insert(socket, :chats, %{id: id, model: name, content: :loading})
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({_, {id, name, %{results: %{text: text}}}}, %{assigns: %{loading: loading}} = socket) do
    Logger.info("Received response for #{name} model with id #{id}")

    socket =
      socket
      |> stream_insert(:chats, %{id: id, model: name, content: text})
      |> assign(:loading, loading - 1)

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
