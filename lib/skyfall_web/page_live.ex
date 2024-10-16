defmodule SkyfallWeb.PageLive do
  use SkyfallWeb, :live_view
  require Logger
  alias Skyfall.Models

  @impl true
  def mount(_params, _session, socket) do
    cache =
      Enum.reduce(Models.models(), %{}, fn %{name: name}, cache ->
        Map.put(cache, name, %{})
      end)

    socket =
      socket
      |> stream(:chats, [])
      |> assign(:model, nil)
      |> assign(:loading, 0)
      |> assign(:cache, cache)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen bg-gray-100 flex items-center justify-between p-5 gap-3">
      <div class="grow flex flex-col bg-white rounded-xl border-2 h-full w-full">
        <div class="grow h-full p-2 flex flex-col" id="chats" phx-update="stream">
          <div
            :for={{dom_id, %{model: model, content: content}} <- @streams.chats}
            class={"w-1/2 rounded-xl p-2 mb-1 text-gray-800 #{content == :loading && "animate-pulse bg-green-300"} #{if model, do: "bg-green-100", else: "bg-blue-100 self-end"}"}
            id={dom_id}
          >
            <%= if content == :loading, do: "#{model} is thinking", else: "#{if model, do: "#{model}: "}#{content}" %>
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
        target_pid = self()

        Task.async(fn ->
          Nx.Serving.batched_run({:local, name}, text)
          |> Stream.map(&send(target_pid, {:new_token, %{id: id, model: name, content: &1}}))
          |> Stream.run()

          name
        end)

        stream_insert(socket, :chats, %{id: id, model: name, content: :loading})
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_token, new_token}, %{assigns: %{cache: cache}} = socket) do
    {_, cache} =
      cache
      |> Map.get_and_update!(new_token.model, fn current_value ->
        cond do
          Map.has_key?(current_value, :id) ->
            {current_value, Map.update(current_value, :content, "", fn value -> value <> new_token.content end)}

          true ->
            {current_value, new_token}
        end
      end)

    to_insert = Map.get(cache, new_token.model)

    socket =
      socket
      |> stream_insert(:chats, to_insert)
      |> assign(:cache, cache)

    {:noreply, socket}
  end

  def handle_info({_, name}, %{assigns: %{loading: loading, cache: cache}} = socket) do
    {_, cache} = Map.get_and_update!(cache, name, fn current_value -> {current_value, %{}} end)
    socket = socket |> assign(:loading, loading - 1) |> assign(:cache, cache)
    Logger.info("Model #{name} finished processing")
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
