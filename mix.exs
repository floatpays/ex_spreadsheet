defmodule Spreadsheet.MixProject do
  use Mix.Project

  @github_url "https://github.com/wkirschbaum/ex_spreadsheet"
  @version "0.1.1"

  def project do
    [
      app: :spreadsheet,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler_precompiled, "~> 0.8.1"},
      {:rustler, "~> 0.36.1", runtime: false, optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*",
        "native/spreadsheet/.cargo",
        "native/spreadsheet/src",
        "native/spreadsheet/Cargo*",
        "checksum-*.exs"
      ],
      maintainers: ["Wilhelm H Kirschbaum"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
    ]
  end

  defp description do
    "Parse Spreadsheet files using Rustler and Calamine."
  end
end
