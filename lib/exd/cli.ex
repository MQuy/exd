defmodule Exd.CLI do

  def main(argv) do
    Exd.start(:ok, :info)

    argv
    |> parse_args
    |> process
  end

  defp parse_args(argv) do
    {opts, links, _} =
      OptionParser.parse(argv,
                         switches: [async: :boolean, watch: :boolean, input_file: :string],
                         aliases: [a: :async])
    opts = Enum.reduce(opts, %{}, fn({key, value}, acc) -> Map.put(acc, key, value) end)
    {links, opts}
  end

  defp process({_, %{watch: true}}), do: Exd.Watcher.listen
  defp process({links, opts}) do
    input_file = Map.get(opts, :input_file, "")

    links
    |> command_links(input_file)
    |> queue_links(opts)
  end

  defp command_links(links, input_file) do
    input_links =
      case File.read(input_file) do
        {:ok, body} -> String.split(body, ~r/\n/, trim: true)
        _ -> []
      end
    links ++ input_links |> Enum.uniq
  end

  defp queue_links(links, %{async: true}) do
    Enum.each(links, fn(link) ->
      %Exd.Download.File{url: link}
      |> Poison.encode!
      |> Exd.Redis.Client.push
    end)
    :timer.sleep 50
  end
  defp queue_links(links, _) do
    links
    |> Enum.each(&(Exd.Download.Tool.fetch(&1)))

    Exd.Download.Output.print
  end
end
