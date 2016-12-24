defmodule Exd.Mixfile do
  use Mix.Project

  def project do
    [app: :exd,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: [main_module: Exd.CLI],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:httpoison, :logger, :redix, :redix_pubsub],
     mod: {Exd, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.10.0"},
     {:progress_bar, "~> 1.5.0"},
     {:redix, "~> 0.4.0"},
     {:redix_pubsub, ">= 0.1.1"},
     {:poison, "~> 3.0"}]
  end
end
