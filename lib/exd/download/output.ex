defmodule Exd.Download.Output do

  def print(previous_pids \\ [], loop \\ false) do
    pids = current_process
    case execute(pids, previous_pids) do
      {:ok, :in_progress} -> print(pids, loop)
      {:ok, :finished} -> if loop, do: print(pids, loop)
    end
  end

  defp execute(pids, previous_pids) do
    prepare_screen(previous_pids)
    clear_screen
    with files <- Enum.map(pids, &tap_file/1),
         true <- Enum.all?(files, &(Exd.Download.File.finished?(&1))) do
      {:ok, :finished}
     else
       _ -> {:ok, :in_progress}
    end
  end

  defp prepare_screen([]), do: :nothing
  defp prepare_screen(previous_pids) do
    :timer.sleep 50
    previous_pids |> Enum.count |> move_cursor
  end

  defp tap_file(pid) do
    file = Exd.Download.Tool.get(pid)
    Exd.LineFormat.render(file, pid)
    file
  end

  defp move_cursor(step) when step > 0, do: IO.write("\e[#{step}A")
  defp move_cursor(_), do: :nothing

  defp clear_screen, do: IO.write("\e[0J")

  defp current_process do
    Exd.Download.Supervisor
    |> Supervisor.which_children
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.sort
  end
end
