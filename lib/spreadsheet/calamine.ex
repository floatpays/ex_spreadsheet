defmodule Spreadsheet.Calamine do
  @moduledoc false

  config = Mix.Project.config()

  version = config[:version]
  github_url = config[:github_url]

  use RustlerPrecompiled,
    otp_app: :spreadsheet,
    crate: "spreadsheet",
    base_url: "#{github_url}/releases/download/v#{version}",
    version: version

  def sheet_names_from_binary(_content),
    do: :erlang.nif_error(:nif_not_loaded)

  def sheet_names_from_path(_path),
    do: :erlang.nif_error(:nif_not_loaded)

  def parse_from_binary(_content, _sheet_name),
    do: :erlang.nif_error(:nif_not_loaded)

  def parse_from_path(_path, _sheet_name),
    do: :erlang.nif_error(:nif_not_loaded)
end
