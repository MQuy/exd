defmodule Exd.Redis.PubSub do
  use GenServer

  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  # Server
  def init(_) do
    {:ok, pubsub} = Redix.PubSub.start_link()
    Redix.PubSub.subscribe(pubsub, "exd_queue", self())

    {:ok, pubsub}
  end

  def handle_info({:redix_pubsub, _, :message, %{channel: "exd_queue", payload: payload}}, state) do
    file = payload |> Poison.decode!(as: %Exd.Download.File{})
    Exd.Download.Tool.fetch(file.url)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
