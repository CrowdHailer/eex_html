defmodule EExHTML.MixProject do
  use Mix.Project

  def project do
    [
      app: :eex_html,
      version: "0.2.1",
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
      # `:eex` added to reduce dialyzer warnings
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
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
