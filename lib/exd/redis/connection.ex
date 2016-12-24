defmodule Exd.Redis.Connection do
  use GenServer

  @database 3
  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  # Server
  def init(_) do
    Redix.start_link([database: @database], name: :exd)
  end

  def handle_cast({:set, key, value}, conn) do
    command(conn, ["SET", key, value])
    {:noreply, conn}
  end

  def handle_cast({:lpush, key, value}, conn) do
    command(conn, ["RPUSH", key, value])
    {:noreply, conn}
  end

  def handle_cast({:publish, channel, info}, conn) do
    command(conn, ["PUBLISH", channel, info])
    {:noreply, conn}
  end

  def handle_cast({:zadd, key, score, value}, conn) do
    command(conn, ["ZADD", key, score, value])
    {:noreply, conn}
  end

  def handle_cast({:zremrangebyscore, key, start, stop}, conn) do
    command(conn, ["ZREMRANGEBYSCORE", key, start, stop])
    {:noreply, conn}
  end

  def handle_call({:get, key}, _from, conn) do
    {:ok, value} = command(conn, ["GET", key])
    {:reply, value, conn}
  end

  def handle_call({:keys, pattern}, _from, conn) do
    {:ok, keys} = command(conn, ["KEYS", pattern])
    {:noreply, keys, conn}
  end

  def handle_call({:lrange, key, start, stop}, _from, conn) do
    {:ok, range} = command(conn, ["LRANGE", key, start, stop])
    {:reply, range, conn}
  end

  def handle_call({:llen, key}, _from, conn) do
    {:ok, length} = command(conn, ["LLEN", key])
    {:reply, length, conn}
  end

  def handle_call({:zrange, key, start, stop}, _from, conn) do
    {:ok, range} = command(conn, ["ZRANGE", key, start, stop])
    {:reply, range, conn}
  end

  def handle_call({:zrangebyscore, key, start, stop}, _from, conn) do
    {:ok, range} = command(conn, ["ZRANGEBYSCORE", key, start, stop])
    {:reply, range, conn}
  end

  defp command(conn, args) do
    Redix.command(conn, args)
  end
end
