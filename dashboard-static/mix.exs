defmodule DashboardStatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :dashboard_static,
      version: "1.0.0",
      elixir: "~> 1.15",
      deps: deps(),
      name: "Jeff Paradox Dashboard (Static)",
      description: "Static metrics dashboard for GitHub Pages"
    ]
  end

  defp deps do
    [
      {:serum, "~> 1.5"},
      {:jason, "~> 1.4"},
      # For JSON-LD generation
      {:json_ld, "~> 0.3", optional: true}
    ]
  end
end
