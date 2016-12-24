defmodule Exd.Utils do

  def http_headers(poison_headers) do
    Enum.reduce(poison_headers, %{}, fn {key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end
end
