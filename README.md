# Adsb

Receiving ADSB encoded messages from Dump1090 via a socket connection and decoding the messages.

Future plans are to implement some kind of mapping, maybe as a web page using Pheonix. Right now, just trying to decode all the message types and learn Elixir along the way.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `adsb` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:adsb, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/adsb>.

