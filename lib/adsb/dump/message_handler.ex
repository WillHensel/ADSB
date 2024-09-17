defmodule Dump.MessageDecoder do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def decode_message(message_decoder, message) do
    GenServer.call(message_decoder, {:decode_message, message})
  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:decode_message, message}, _, _) do
    message = decode_frame(message, String.length(message))

    {:reply, message, nil}
  end

  def decode_frame(frame, frame_length) when frame_length == 31 do
    frame =
      frame
      |> String.trim_leading("*")
      |> String.trim_trailing("\n")
      |> String.trim_trailing(";")

    dfca = String.slice(frame, 0..1)
    icao = String.slice(frame, 2..7)
    message = String.slice(frame, 8..21)
    pi = String.slice(frame, 22..27)

    <<df::size(5), ca::size(3)>> = dfca |> Base.decode16!()

    %{
      downlink_format: df,
      capability: ca,
      icao: icao,
      message: decode_me(message),
      pi: pi
    }
  end

  def decode_frame(_, _) do
  end

  defp decode_me(message) do
    message_types = %{
      1 => &Dump.Decoder.AircraftIdentification.decode/1,
      2 => &Dump.Decoder.AircraftIdentification.decode/1,
      3 => &Dump.Decoder.AircraftIdentification.decode/1,
      4 => &Dump.Decoder.AircraftIdentification.decode/1,
      5 => &Dump.Decoder.SurfacePosition.decode/1,
      6 => &Dump.Decoder.SurfacePosition.decode/1,
      7 => &Dump.Decoder.SurfacePosition.decode/1,
      8 => &Dump.Decoder.SurfacePosition.decode/1,
      9 => &Dump.Decoder.AirbornePosition.decode/1,
      10 => &Dump.Decoder.AirbornePosition.decode/1,
      11 => &Dump.Decoder.AirbornePosition.decode/1,
      12 => &Dump.Decoder.AirbornePosition.decode/1,
      13 => &Dump.Decoder.AirbornePosition.decode/1,
      14 => &Dump.Decoder.AirbornePosition.decode/1,
      15 => &Dump.Decoder.AirbornePosition.decode/1,
      16 => &Dump.Decoder.AirbornePosition.decode/1,
      17 => &Dump.Decoder.AirbornePosition.decode/1,
      18 => &Dump.Decoder.AirbornePosition.decode/1,
      19 => &Dump.Decoder.AirborneVelocity.decode/1,
      20 => &Dump.Decoder.AirbornePosition.decode/1,
      21 => &Dump.Decoder.AirbornePosition.decode/1,
      22 => &Dump.Decoder.AirbornePosition.decode/1,
      23 => fn _ -> %{} end,
      24 => fn _ -> %{} end,
      25 => fn _ -> %{} end,
      26 => fn _ -> %{} end,
      27 => fn _ -> %{} end,
      28 => fn _ -> %{} end,
      29 => fn _ -> %{} end,
      31 => &Dump.Decoder.OperationStatus.decode/1
    }

    <<message_type::size(5), _::bitstring>> = message |> Base.decode16!()

    message_types[message_type].(message)
  end
end
