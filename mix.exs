defmodule EExHTML.MixProject do
  use Mix.Project

  def project do
    [
      app: :eex_html,
      version: "1.0.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: [],
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      # Dialyzer not useful on this project.
      # Doesn't play nice with protocols https://github.com/elixir-lang/elixir/issues/7708
      # {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Extension to Embedded Elixir (EEx), that allows content to be safely embedded into HTML.
    """
  end

  defp package do
    [
      maintainers: ["Peter Saxton"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/crowdhailer/eex_html"}
    ]
  end
end
