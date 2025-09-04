defmodule Spreadsheet do
  @moduledoc """
  A fast, memory-efficient Elixir library for parsing spreadsheet files.

  This library provides a simple API for working with Excel (.xlsx, .xls) and
  LibreOffice (.ods) files. It's powered by Rust and Calamine for high-performance
  parsing.

  ## Features

  - Fast performance with native Rust implementation
  - Support for multiple formats: .xls, .xla, .xlsx, .xlsm, .xlam, .xlsb, and .ods
  - Memory efficient parsing from file paths or binary content
  - Sheet management with support for hidden sheets
  - Smart type handling with automatic date and number conversion
  """

  alias Spreadsheet.Calamine

  @doc """
  Returns a list of sheet names from a spreadsheet file.

  Supports Excel (.xlsx, .xls) and LibreOffice (.ods) file formats.

  ## Options

    * `:hidden` - When `false`, excludes hidden sheets. Defaults to `true`.


  """
  @spec sheet_names(String.t(), keyword()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def sheet_names(path, opts \\ []) when is_binary(path) and is_list(opts) do
    include_hidden = Keyword.get(opts, :hidden, true)
    Calamine.sheet_names_from_path(path, include_hidden)
  end

  @doc """
  Parses a specific sheet from a spreadsheet file.

  Returns the sheet data as a list of lists, where each inner list represents a row.
  The first row typically contains headers.

  Dates are automatically parsed to `NaiveDateTime` when possible, and empty cells
  are converted to `nil`.


  """
  @spec parse(String.t(), binary()) ::
          {:ok, list()} | {:error, binary()}
  def parse(path, sheet_name) do
    Calamine.parse_from_path(path, sheet_name)
    |> case do
      {:ok, rows} -> {:ok, parse_rows(rows)}
      other -> other
    end
  end

  @doc """
  Returns a list of sheet names from spreadsheet binary content.

  This function is useful when you have the spreadsheet content in memory
  rather than as a file on disk.

  ## Options

    * `:hidden` - When `false`, excludes hidden sheets. Defaults to `true`.


  """
  @spec sheet_names_from_binary(binary(), keyword()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def sheet_names_from_binary(content, opts \\ [])
      when is_binary(content) and is_list(opts) do
    include_hidden = Keyword.get(opts, :hidden, true)
    Calamine.sheet_names_from_binary(content, include_hidden)
  end

  @doc """
  Parses a specific sheet from spreadsheet binary content.

  This function is useful when you have the spreadsheet content in memory
  rather than as a file on disk. Returns the sheet data as a list of lists,
  where each inner list represents a row.

  Dates are automatically parsed to `NaiveDateTime` when possible, and empty cells
  are converted to `nil`.


  """
  @spec parse_from_binary(binary(), binary()) ::
          {:ok, list()} | {:error, String.t()}
  def parse_from_binary(content, sheet_name) do
    Calamine.parse_from_binary(
      content,
      sheet_name
    )
    |> case do
      {:ok, rows} -> {:ok, parse_rows(rows)}
      other -> other
    end
  end

  defp parse_rows(rows) do
    for row <- rows do
      for col <- row, do: parse_col(col)
    end
  end

  defp parse_col(:empty), do: nil

  defp parse_col({:date_time, val}) do
    case NaiveDateTime.from_iso8601(val) do
      {:ok, dt} -> dt
      _ -> val
    end
  end

  defp parse_col({_, val}), do: val
end
