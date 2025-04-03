defmodule Spreadsheet.Calamine do
  @moduledoc false

  use RustlerPrecompiled,
    otp_app: :spreadsheet,
    crate: "spreadsheet",
    base_url:
      "https://github.com/wkirschbaum/ex_spreadsheet/releases/download/v0.1.0",
    version: "0.1.0",
    nif_versions: ["2.17"]

  def sheet_names_from_binary(_content),
    do: :erlang.nif_error(:nif_not_loaded)

  def sheet_names_from_path(_path),
    do: :erlang.nif_error(:nif_not_loaded)

  def parse_from_binary(_content, _sheet_name),
    do: :erlang.nif_error(:nif_not_loaded)

  def parse_from_path(_path, _sheet_name),
    do: :erlang.nif_error(:nif_not_loaded)
end
