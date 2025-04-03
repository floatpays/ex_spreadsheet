defmodule Spreadsheet.MixProject do
  use Mix.Project

  def project do
    [
      app: :spreadsheet,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
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
      {:rustler_precompiled, "~> 0.8"},
      {:rustler, "~> 0.36.1", runtime: false, optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      organization: "floatpays",
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
      links: %{"GitHub" => "https://github.com/floatpays/spreadsheet"}
    ]
  end

  defp description do
    "Parses spreadsheet data using the Calamine via a Rustler NIF."
  end
end
