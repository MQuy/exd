defmodule Exd.Download.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_child do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Exd.Download.Tool, [%Exd.Download.File{}], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
