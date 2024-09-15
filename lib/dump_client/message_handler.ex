defmodule DumpClient.MessageDecoder do
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
      1 => &DumpClient.Decoder.AircraftIdentification.decode/1,
      2 => &DumpClient.Decoder.AircraftIdentification.decode/1,
      3 => &DumpClient.Decoder.AircraftIdentification.decode/1,
      4 => &DumpClient.Decoder.AircraftIdentification.decode/1,
      5 => &DumpClient.Decoder.SurfacePosition.decode/1,
      6 => &DumpClient.Decoder.SurfacePosition.decode/1,
      7 => &DumpClient.Decoder.SurfacePosition.decode/1,
      8 => &DumpClient.Decoder.SurfacePosition.decode/1,
      9 => &DumpClient.Decoder.AirbornePosition.decode/1,
      10 => &DumpClient.Decoder.AirbornePosition.decode/1,
      11 => &DumpClient.Decoder.AirbornePosition.decode/1,
      12 => &DumpClient.Decoder.AirbornePosition.decode/1,
      13 => &DumpClient.Decoder.AirbornePosition.decode/1,
      14 => &DumpClient.Decoder.AirbornePosition.decode/1,
      15 => &DumpClient.Decoder.AirbornePosition.decode/1,
      16 => &DumpClient.Decoder.AirbornePosition.decode/1,
      17 => &DumpClient.Decoder.AirbornePosition.decode/1,
      18 => &DumpClient.Decoder.AirbornePosition.decode/1,
      19 => &DumpClient.Decoder.AirborneVelocity.decode/1,
      20 => &DumpClient.Decoder.AirbornePosition.decode/1,
      21 => &DumpClient.Decoder.AirbornePosition.decode/1,
      22 => &DumpClient.Decoder.AirbornePosition.decode/1,
      23 => fn _ -> %{} end,
      24 => fn _ -> %{} end,
      25 => fn _ -> %{} end,
      26 => fn _ -> %{} end,
      27 => fn _ -> %{} end,
      28 => fn _ -> %{} end,
      29 => fn _ -> %{} end,
      31 => &DumpClient.Decoder.OperationStatus.decode/1
    }

    <<message_type::size(5), _::bitstring>> = message |> Base.decode16!()

    message_types[message_type].(message)
  end
end
