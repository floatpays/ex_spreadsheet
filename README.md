# Spreadsheet

<!-- MDOC !-->

Native Implementation Function ( NIF ) bindings for ([Calamine](https://docs.rs/calamine/latest/calamine/)) to read Excel and OpenDocument Spreadsheet files.


## Usage

To retrieve sheet names:

```elixir
iex> Spreadsheet.sheet_names("test_file_1.xlsx")

{:ok, ["sheet1"]}
```

Or from a binary:

```elixir
iex> Spreadsheet.sheet_names_from_bianry(File.read!("test_file_1.xlsx"))

{:ok, ["sheet1"]}
```

To retrieve rows:

```elixir
iex> Spreadsheet.parse("test_file_1.xlsx")

{:ok, [["row1col1", "row1col2"], ["row2col1", "row2col2"]]}
```

Or from a binary:

```elixir
iex> Spreadsheet.parse(File.read!("test_file_1.xlsx"))

{:ok, [["row1col1", "row1col2"], ["row2col1", "row2col2"]]}
```


Note that all dates will be retrieved as NaiveDateTime, and all numbers as Float.

For further documentation on how rows gets parsed, view the Calamine documentation: 

https://docs.rs/calamine/latest/calamine/

<!-- MDOC !-->

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xlsx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:spreadsheet, "~> 0.1.0"}
  ]
end
```

By default **you don't need Rust installed** because the lib will try to download
a precompiled NIF file. In case you want to force compilation set the
application env in order to force the build:

```elixir
config :rustler_precompiled, :force_build, spreadsheet: true
```


## Development

### Publishing a new version

As per instruction: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html

- release a new tag
- push the code to your repository with the new tag: git push origin main --tags
- wait for all NIFs to be built
- run the mix rustler_precompiled.download task (with the flag --all)
- release the package to Hex.pm (make sure your release includes the correct files).


    mix rustler_precompiled.download SpreadSheet.Calamine --all

## Copyright and License

Copyright (c) 2025 Wilhelm H Kirschbaum

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
