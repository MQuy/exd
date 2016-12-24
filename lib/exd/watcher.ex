defmodule Exd.Watcher do

  def listen do
    connections
    |> Enum.map(&(&1.url))
    |> Enum.each(&(Exd.Download.Tool.fetch(&1)))

    Exd.Download.Output.print([], true)
  end

  defp connections do
    Exd.Redis.Client.lrange(0, -1)
    |> Enum.map(&(Poison.decode!(&1, as: %Exd.Download.File{})))
    |> Enum.filter(&(Exd.Download.File.pending?(&1)))
  end
end
