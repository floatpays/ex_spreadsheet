# Spreadsheet

<!-- MDOC !-->

Parse Spreadsheet files using Rustler and [Calamine](https://docs.rs/calamine/latest/calamine/).

File formats supported are .xls, .xla, .xlsx, .xlsm, .xlam, .xlsb, and .ods.

## Usage

To retrieve sheet names:

```elixir
iex> Spreadsheet.sheet_names("test_file_1.xlsx")

{:ok, ["sheet1"]}
```

Or from a binary:

```elixir
iex> Spreadsheet.sheet_names_from_binary(File.read!("test_file_1.xlsx"))

{:ok, ["sheet1"]}
```

To retrieve rows:

```elixir
iex> Spreadsheet.parse("test_file_1.xlsx")

{:ok, [["row1col1", "row1col2"], ["row2col1", "row2col2"]]}
```

Or from a binary:

```elixir
iex> Spreadsheet.parse_from_binary(File.read!("test_file_1.xlsx"))

{:ok, [["row1col1", "row1col2"], ["row2col1", "row2col2"]]}
```


Note that all dates will be retrieved as NaiveDateTime, and all numbers as Float.

For further documentation on how rows are parsed, view the Calamine documentation: 

https://docs.rs/calamine/latest/calamine/

<!-- MDOC !-->

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `spreadsheet` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spreadsheet, "~> 0.2.0"}
  ]
end
```

By default **you don't need Rust installed** because the lib will try to download
a precompiled NIF file. In case you want to force compilation set the
application env in order to force the build:

```elixir
config :rustler_precompiled, :force_build, spreadsheet: true
```

## Alternatives

- [XlsxReader](https://hex.pm/packages/xlsx_reader)
- [Xlsxir](https://hex.pm/packages/xlsxir)

## Development

### Publishing a new version

Follow the [rustler_precompiled guide](https://hexdocs.pm/rustler_precompiled/precompilation_guide.html):

1. Release a new tag
2. Push the code with the new tag: `git push origin main --tags`
3. Wait for all NIFs to be built
4. Download precompiled NIFs: `mix rustler_precompiled.download Spreadsheet.Calamine --all`
5. Release the package to Hex.pm


## Copyright and License

Copyright (c) 2025 Wilhelm H Kirschbaum

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
