defmodule Exd.ProgressBar do
  @bar_format [
    bar: "=",
    blank: " ",
    left: "[", right: "]",
    blank_color: IO.ANSI.magenta,
    bytes: true,
    width: 200
  ]

  def render(acc, total, new_line \\ false) do
    ProgressBar.render(acc, total, @bar_format)
    render_new_link(new_line && acc < total)
  end

  defp render_new_link(true), do: IO.write("\n")
  defp render_new_link(_), do: ""
end
