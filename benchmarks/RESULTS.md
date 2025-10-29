# XLSX Reading Benchmark Results

**Date:** 2025-10-29 06:23:10.891490Z

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
| xlsx_reader | 911.37 | 1.1 ms | 442.33 KB |
| xlsx_parser | 1037.58 | 963.78 μs | 1.61 MB |
| spreadsheet | 10715.02 | 93.33 μs | 2.71 KB |

### Large File (10,000 rows × 20 columns)

| Library | Operations/sec | Average Time | Memory Usage |
|---------|---------------|--------------|--------------|
| xlsx_reader | 0.66 | 1.51 s | 731.89 MB |
| xlsx_parser | 0.36 | 2.81 s | 3800.93 MB |
| spreadsheet | 6.7 | 149.31 ms | 3.21 MB |

## Environment

- **CPU**: 11th Gen Intel(R) Core(TM) i5-11500H @ 2.90GHz
- **CPU Cores**: 4 cores available
- **Memory**: 30.58 GB
- **Elixir**: 1.19.1
- **Erlang/OTP**: 28
- **OS**: Linux (kernel 6.17.0-5-generic)
