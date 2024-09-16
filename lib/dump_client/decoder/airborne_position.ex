defmodule DumpClient.Decoder.AirbornePosition do
  @doc """
  Does not contain context with other messages so decoded values are still in the
  Compact Position Reporting (CPR) format and need to be combined with corresponding
  messages at a later time to find the true latitude and longitude of the aircraft.
  """
  def decode(message) do
    <<type_code::size(5), surveillance_status::size(2), _::size(1), encoded_altitude::size(12),
      _::size(1), cpr_format::size(1), encoded_latitude::size(17),
      encoded_longitude::size(17)>> = message |> Base.decode16!()

    %Message.AirbornePosition{
      type_code: type_code,
      surveillance_status: decode_surveillance_status(surveillance_status),
      altitude: decode_altitude(encoded_altitude, type_code),
      cpr_format: cpr_format,
      encoded_latitude: encoded_latitude,
      encoded_longitude: encoded_longitude
    }
  end

  defp decode_surveillance_status(status) do
    case status do
      0 -> "No condition"
      1 -> "Permanent alert"
      2 -> "Temporary alert"
      3 -> "SPI condition"
    end
  end

  defp decode_altitude(encoded, type_code) when type_code in 9..18 do
    # Decoding using barometric altitude

    <<first::size(7), q::size(1), last::size(4)>> = <<encoded::12>>
    bin = <<0::5, first::7, last::4>> |> :binary.decode_unsigned()

    case q do
      1 -> 25 * bin - 1000
      # TODO gray code decoding (no example provided by book)
      2 -> 0
    end
  end

  defp decode_altitude(encoded, type_code) when type_code in 20..22 do
    # Decoding using GNSS height

    # Convert meters to feet
    encoded * 3.281
  end
end
