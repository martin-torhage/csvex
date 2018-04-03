defmodule Csvex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :csvex,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "Elixir CSV parser using high performance NIF",
      package: package(),
      deps: [{:ex_doc, "~> 0.18.0", only: :dev}],
      source_url: "https://github.com/martin-torhage/csvex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:csv, "~> 3.0", hex: :csve}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Martin Torhage"],
      links: %{"GitHub" => "https://github.com/martin-torhage/csvex"},
    ]
  end
end
