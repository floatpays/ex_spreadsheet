defmodule Spreadsheet do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Spreadsheet.Calamine

  @doc """
  Returns a list of sheet names.
  """
  @spec sheet_names(String.t()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def sheet_names(path) when is_binary(path) do
    Calamine.sheet_names_from_path(path)
  end

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
  Returns a list of sheet names.
  """
  @spec sheet_names_from_binary(binary()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def sheet_names_from_binary(content) when is_binary(content) do
    Calamine.sheet_names_from_binary(content)
  end

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
