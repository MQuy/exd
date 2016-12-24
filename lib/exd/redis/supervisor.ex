defmodule Exd.Redis.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Exd.Redis.Connection, [], restart: :permanent),
      worker(Exd.Redis.PubSub, [], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
