defmodule Exd.Redis.Client do
  @connection_name Exd.Redis.Connection
  @lish_name "exd"
  @channel_name "exd_queue"

  def set(key, value) do
    GenServer.cast(@connection_name, {:set, key, value})
  end

  def push(value) do
    push(@lish_name, value)
  end
  def push(key, value) do
    GenServer.cast(@connection_name, {:lpush, key, value})
    publish(value)
  end

  def publish(info) do
    publish(@channel_name, info)
  end
  def publish(channel_name, info) do
    GenServer.cast(@connection_name, {:publish, channel_name, info})
  end

  def lrange(start, stop) do
    lrange(@lish_name, start, stop)
  end
  def lrange(key, start, stop) do
    GenServer.call(@connection_name, {:lrange, key, start, stop})
  end
end
