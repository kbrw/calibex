defmodule Calibex.Mixfile do
  use Mix.Project

  def project do
    [app: :calibex,
     version: "0.1.0",
     elixir: "~> 1.3",
     package: package(),
     description: description(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:tz, "~> 0.25.1", only: :test}
    ]
  end

  defp package do
    [ maintainers: ["Arnaud Wetzel"],
      licenses: ["The MIT License (MIT)"],
      links: %{ "GitHub"=>"https://github.com/kbrw/calibex" } ]
  end

  defp description do
    """
    Calibex is an ICal Elixir library which focus in bijective coding/decoding in order to allow
    ICal transformation, ICal email request and responses, and easy non-standard fields inclusion.
    """
  end
end
