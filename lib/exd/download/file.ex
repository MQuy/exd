defmodule Exd.Download.File do
  defstruct size: 0, downloaded: 0, type: nil, url: nil, file_name: nil, state: :pending

  states = [:pending, :initialize, :accepted, :started, :downloading, :finished]

  for state <- states do
    fun_name = String.to_atom("#{state}?")

    def unquote(fun_name)(%{state: state}) when is_atom(state) do
      state == unquote(state)
    end
    def unquote(fun_name)(%{state: state}) do
      state == unquote(state) |> Atom.to_string
    end
  end
end
