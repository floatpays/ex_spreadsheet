#!/usr/bin/env elixir

# Benchmark comparing xlsx_reader vs xlsx_parser vs spreadsheet
# This script creates test XLSX files and benchmarks reading performance

Mix.install([
  {:xlsx_reader, "~> 0.8.8"},
  {:xlsx_parser, "~> 0.1.2"},
  {:xlsx_writer, "~> 0.6.0"},
  {:benchee, "~> 1.0"},
  {:spreadsheet, path: ".."}
])

defmodule BenchmarkHelper do
  @doc """
  Creates a small XLSX file (10 rows x 5 columns)
  """
  def create_small_file(path) do
    sheet = XlsxWriter.new_sheet("Sheet1")

    header = ["Name", "Age", "Email", "Salary", "Join Date"]

    sheet =
      Enum.with_index(header)
      |> Enum.reduce(sheet, fn {value, col}, acc ->
        XlsxWriter.write(acc, 0, col, value, [])
      end)

    sheet =
      for i <- 1..10, reduce: sheet do
        acc ->
          row_data = [
            "Person #{i}",
            20 + i,
            "person#{i}@example.com",
            50000 + i * 1000,
            "2024-01-#{String.pad_leading("#{i}", 2, "0")}"
          ]

          Enum.with_index(row_data)
          |> Enum.reduce(acc, fn {value, col}, sheet_acc ->
            XlsxWriter.write(sheet_acc, i, col, value, [])
          end)
      end

    {:ok, binary} = XlsxWriter.generate([sheet])
    File.write!(path, binary)
  end

  @doc """
  Creates a large XLSX file (10,000 rows x 20 columns)
  """
  def create_large_file(path) do
    IO.puts("Creating large test file with 10,000 rows...")

    sheet = XlsxWriter.new_sheet("Sheet1")

    # Write header
    sheet =
      for i <- 1..20, reduce: sheet do
        acc -> XlsxWriter.write(acc, 0, i - 1, "Column #{i}", [])
      end

    # Write data rows
    sheet =
      for i <- 1..10_000, reduce: sheet do
        acc ->
          for j <- 1..20, reduce: acc do
            sheet_acc ->
              value =
                case rem(j, 4) do
                  0 -> i * j
                  1 -> "Text #{i}-#{j}"
                  2 -> i + j / 10
                  3 -> "2024-#{rem(i, 12) + 1}-#{rem(i, 28) + 1}"
                end

              XlsxWriter.write(sheet_acc, i, j - 1, value, [])
          end
      end

    {:ok, binary} = XlsxWriter.generate([sheet])
    File.write!(path, binary)
    IO.puts("Large test file created successfully")
  end
end

# Setup test files
small_file = "/tmp/benchmark_small.xlsx"
large_file = "/tmp/benchmark_large.xlsx"

IO.puts("Setting up test files...")
BenchmarkHelper.create_small_file(small_file)
BenchmarkHelper.create_large_file(large_file)

IO.puts("\n" <> String.duplicate("=", 80))
IO.puts("BENCHMARK: xlsx_reader vs xlsx_parser vs spreadsheet")
IO.puts(String.duplicate("=", 80) <> "\n")

IO.puts("Test files created:")
IO.puts("  - Small: 10 rows x 5 columns")
IO.puts("  - Large: 10,000 rows x 20 columns")
IO.puts("")

# Store results for markdown
results = %{}

IO.puts("\n--- READING SMALL FILE (10 rows x 5 cols) ---\n")

small_results =
  Benchee.run(
    %{
      "xlsx_reader" => fn ->
        {:ok, package} = XlsxReader.open(small_file)
        {:ok, rows} = XlsxReader.sheet(package, "Sheet1")
        rows
      end,
      "xlsx_parser" => fn ->
        {:ok, data} = XlsxParser.get_sheet_content(small_file, 1)
        data
      end,
      "spreadsheet" => fn ->
        {:ok, rows} = Spreadsheet.parse(small_file, "Sheet1")
        rows
      end
    },
    time: 5,
    memory_time: 2,
    formatters: [Benchee.Formatters.Console]
  )

IO.puts("\n--- READING LARGE FILE (10,000 rows x 20 cols) ---\n")

large_results =
  Benchee.run(
    %{
      "xlsx_reader" => fn ->
        {:ok, package} = XlsxReader.open(large_file)
        {:ok, rows} = XlsxReader.sheet(package, "Sheet1")
        rows
      end,
      "xlsx_parser" => fn ->
        {:ok, data} = XlsxParser.get_sheet_content(large_file, 1)
        data
      end,
      "spreadsheet" => fn ->
        {:ok, rows} = Spreadsheet.parse(large_file, "Sheet1")
        rows
      end
    },
    time: 5,
    memory_time: 2,
    formatters: [Benchee.Formatters.Console]
  )

IO.puts("\n" <> String.duplicate("=", 80))
IO.puts("Benchmark complete!")
IO.puts(String.duplicate("=", 80))

# Helper functions for system info
defmodule SystemInfo do
  def get_cpu_info do
    case :os.type() do
      {:unix, _} ->
        case System.cmd("cat", ["/proc/cpuinfo"]) do
          {output, 0} ->
            output
            |> String.split("\n")
            |> Enum.find(&String.contains?(&1, "model name"))
            |> case do
              nil -> "Unknown CPU"
              line -> line |> String.split(":") |> List.last() |> String.trim()
            end

          _ ->
            "Unknown CPU"
        end

      _ ->
        "Unknown CPU"
    end
  rescue
    _ -> "Unknown CPU"
  end

  def get_memory_info do
    case :os.type() do
      {:unix, _} ->
        case System.cmd("cat", ["/proc/meminfo"]) do
          {output, 0} ->
            output
            |> String.split("\n")
            |> Enum.find(&String.starts_with?(&1, "MemTotal:"))
            |> case do
              nil ->
                "Unknown"

              line ->
                line
                |> String.split()
                |> Enum.at(1)
                |> String.to_integer()
                |> Kernel./(1024 * 1024)
                |> Float.round(2)
                |> then(&"#{&1} GB")
            end

          _ ->
            "Unknown"
        end

      _ ->
        "Unknown"
    end
  rescue
    _ -> "Unknown"
  end

  def get_os_info do
    case :os.type() do
      {:unix, :linux} ->
        case System.cmd("uname", ["-r"]) do
          {kernel, 0} -> "Linux (kernel #{String.trim(kernel)})"
          _ -> "Linux"
        end

      {:unix, :darwin} ->
        "macOS"

      {:win32, _} ->
        "Windows"

      other ->
        inspect(other)
    end
  rescue
    _ -> "Unknown OS"
  end
end

# Helper functions for formatting
defmodule BenchmarkFormatter do
  def format_stat(results, name, type) do
    scenario = results.scenarios |> Enum.find(&(&1.name == name))

    case type do
      :ips ->
        if scenario.run_time_data.statistics.ips do
          "#{Float.round(scenario.run_time_data.statistics.ips, 2)}"
        else
          "N/A"
        end

      :average ->
        avg_micro = scenario.run_time_data.statistics.average / 1000

        cond do
          avg_micro < 1000 -> "#{Float.round(avg_micro, 2)} μs"
          avg_micro < 1_000_000 -> "#{Float.round(avg_micro / 1000, 2)} ms"
          true -> "#{Float.round(avg_micro / 1_000_000, 2)} s"
        end

      :memory ->
        if scenario.memory_usage_data && scenario.memory_usage_data.statistics.average do
          bytes = scenario.memory_usage_data.statistics.average

          cond do
            bytes < 1024 -> "#{bytes} B"
            bytes < 1024 * 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
            true -> "#{Float.round(bytes / (1024 * 1024), 2)} MB"
          end
        else
          "N/A"
        end
    end
  end

  def get_winner(results) do
    winner =
      results.scenarios
      |> Enum.max_by(& &1.run_time_data.statistics.ips)

    "**#{winner.name}** (#{Float.round(winner.run_time_data.statistics.ips, 2)} ops/sec)"
  end
end

# Generate markdown report
markdown_content = """
# XLSX Reading Benchmark Results

**Date:** #{DateTime.utc_now() |> DateTime.to_string()}

## Test Setup

This benchmark compares three popular Elixir libraries for reading XLSX files:

- **xlsx_reader** (v0.8.8) - Pure Elixir XLSX parser
- **xlsx_parser** (v0.1.2) - Pure Elixir XLSX parser
- **spreadsheet** (v0.3.0) - Rust-powered parser using Calamine via NIFs

## Test Files

1. **Small file**: 10 rows × 5 columns (mixed data types)
2. **Large file**: 10,000 rows × 20 columns (mixed data types)

Test files were created using **xlsx_writer** (v0.6.0), a Rust-backed Elixir library.

## Results Summary

### Small File (10 rows × 5 columns)

| Library | Operations/sec | Average Time | Memory Usage |
|---------|---------------|--------------|--------------|
| xlsx_reader | #{BenchmarkFormatter.format_stat(small_results, "xlsx_reader", :ips)} | #{BenchmarkFormatter.format_stat(small_results, "xlsx_reader", :average)} | #{BenchmarkFormatter.format_stat(small_results, "xlsx_reader", :memory)} |
| xlsx_parser | #{BenchmarkFormatter.format_stat(small_results, "xlsx_parser", :ips)} | #{BenchmarkFormatter.format_stat(small_results, "xlsx_parser", :average)} | #{BenchmarkFormatter.format_stat(small_results, "xlsx_parser", :memory)} |
| spreadsheet | #{BenchmarkFormatter.format_stat(small_results, "spreadsheet", :ips)} | #{BenchmarkFormatter.format_stat(small_results, "spreadsheet", :average)} | #{BenchmarkFormatter.format_stat(small_results, "spreadsheet", :memory)} |

### Large File (10,000 rows × 20 columns)

| Library | Operations/sec | Average Time | Memory Usage |
|---------|---------------|--------------|--------------|
| xlsx_reader | #{BenchmarkFormatter.format_stat(large_results, "xlsx_reader", :ips)} | #{BenchmarkFormatter.format_stat(large_results, "xlsx_reader", :average)} | #{BenchmarkFormatter.format_stat(large_results, "xlsx_reader", :memory)} |
| xlsx_parser | #{BenchmarkFormatter.format_stat(large_results, "xlsx_parser", :ips)} | #{BenchmarkFormatter.format_stat(large_results, "xlsx_parser", :average)} | #{BenchmarkFormatter.format_stat(large_results, "xlsx_parser", :memory)} |
| spreadsheet | #{BenchmarkFormatter.format_stat(large_results, "spreadsheet", :ips)} | #{BenchmarkFormatter.format_stat(large_results, "spreadsheet", :average)} | #{BenchmarkFormatter.format_stat(large_results, "spreadsheet", :memory)} |

## Environment

- **CPU**: #{SystemInfo.get_cpu_info()}
- **CPU Cores**: #{System.schedulers_online()} cores available
- **Memory**: #{SystemInfo.get_memory_info()}
- **Elixir**: #{System.version()}
- **Erlang/OTP**: #{:erlang.system_info(:otp_release)}
- **OS**: #{SystemInfo.get_os_info()}
"""

File.write!("RESULTS.md", markdown_content)
IO.puts("\n✓ Results saved to RESULTS.md")

# Cleanup
File.rm(small_file)
File.rm(large_file)

IO.puts("✓ Test files cleaned up.")
