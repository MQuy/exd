defmodule Exd.Redis.Client do
  @connection_name Exd.Redis.Connection
  @list_name "exd"
  @channel_name "exd_queue"

  def zadd(score, value, publish? \\ false) do
    zadd(@list_name, score, value, publish?)
  end
  def zadd(key, score, value, publish?) do
    GenServer.cast(@connection_name, {:zadd, key, score, value})
    if publish?, do: publish(value)
  end

  def publish(info) do
    publish(@channel_name, info)
  end
  def publish(channel_name, info) do
    GenServer.cast(@connection_name, {:publish, channel_name, info})
  end

  def zrange(start, stop) do
    zrange(@list_name, start, stop)
  end
  def zrange(key, start, stop) do
    GenServer.call(@connection_name, {:zrange, key, start, stop})
  end

  def zrangebyscore(start, stop) do
    zrangebyscore(@list_name, start, stop)
  end
  def zrangebyscore(key, start, stop) do
    GenServer.call(@connection_name, {:zrangebyscore, key, start, stop})
  end

  def zremrangebyscore(start, stop) do
    zremrangebyscore(@list_name, start, stop)
  end
  def zremrangebyscore(key, start, stop) do
    GenServer.cast(@connection_name, {:zremrangebyscore, key, start, stop})
  end
end
