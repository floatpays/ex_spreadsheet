# Spreadsheet

**TODO: Add description**

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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/xlsx>.

## Development

### Publishing a new version

As per instruction: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html

- release a new tag
- push the code to your repository with the new tag: git push origin main --tags
- wait for all NIFs to be built
- run the mix rustler_precompiled.download task (with the flag --all)
- release the package to Hex.pm (make sure your release includes the correct files).


    mix rustler_precompiled.download SpreadSheet.Calamine --all

