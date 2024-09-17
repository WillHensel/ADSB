defmodule Dump.Decoder.SurfacePosition do
  def decode(message) do
    <<type_code::size(5), movement::size(7), status_ground_track::size(1), ground_track::size(7),
      _::size(1), cpr_format::size(1), encoded_latitude::size(17),
      encoded_longitude::size(17)>> = message |> Base.decode16!()

    %Message.SurfacePosition{
      type_code: type_code,
      movement: decode_movement(<<0, movement>> |> :binary.decode_unsigned()),
      ground_track: decode_ground_track(ground_track, status_ground_track),
      cpr_format: cpr_format,
      encoded_latitude: encoded_latitude,
      encoded_longitude: encoded_longitude
    }
  end

  defp decode_movement(movement) do
    case movement do
      0 -> 0
      x when x in 2..8 -> 0.125 + (movement - 2) * 0.125
      x when x in 9..12 -> 1 + (movement - 9) * 0.25
      x when x in 13..38 -> 2 + (movement - 13) * 0.5
      x when x in 39..93 -> 15 + (movement - 39) * 1
      x when x in 94..108 -> 70 + (movement - 94) * 2
      x when x in 109..123 -> 100 + (movement - 109) * 5
      124 -> 175
      x when x in 125..127 -> 0
    end
  end

  defp decode_ground_track(ground_track, status) do
    case status do
      0 -> 0
      1 -> 360 * ground_track / 128
    end
  end
end
