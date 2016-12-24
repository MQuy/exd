defmodule Exd.Download.Tool do
  use GenServer
  alias Exd.Utils

  def start_link(file) do
    GenServer.start_link(__MODULE__, file)
  end

  def fetch(file) do
    Exd.Download.Supervisor.add_child |> fetch(file)
  end
  def fetch({:ok, pid}, file), do: fetch(pid, file)
  def fetch(pid, file) do
    GenServer.cast(pid, {:fetch, file})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def init(file) do
    {:ok, file}
  end

  def handle_call(:get, _from, file) do
    {:reply, file, file}
  end

  def handle_cast({:fetch, %{url: url} = file}, _) do
    file_name = url |> String.split("/") |> List.last
    new_file =
      file
      |> Map.put(:file_name, file_name)
      |> Map.put(:state, :initialize)
    HTTPoison.get url, %{}, stream_to: self

    {:noreply, new_file}
  end

  def handle_info(%HTTPoison.AsyncStatus{code: 200}, file) do
    new_file = Map.put(file, :state, :accepted)
    {:noreply, new_file}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = poison, file) do
    headers = Utils.http_headers(poison.headers)
    content_length = headers |> Map.get("Content-Length") |> String.to_integer
    new_file =
      file
      |> Map.put(:size, content_length)
      |> Map.put(:type, Map.get(headers, "Content-Type"))
      |> Map.put(:state, :started)

    {:noreply, new_file}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, file) do
    new_file =
      file
      |> Map.put(:downloaded, file.downloaded + byte_size(chunk))
      |> Map.put(:state, :downloading)
    {:noreply, new_file}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, file) do
    new_file = Map.put(file, :state, :finished)
    if new_file.rid do
      Exd.Redis.Client.zremrangebyscore(new_file.rid, new_file.rid)
      Exd.Redis.Client.zadd(new_file.rid, Poison.encode!(new_file))
    end
    {:noreply, new_file}
  end

  def handle_info(_, file) do
    {:noreply, file}
  end
end
