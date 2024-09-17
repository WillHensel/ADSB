defmodule Dump.Decoder.AircraftIdentification do
  def decode(message) do
    <<type_code::size(5), category::size(3), callsign::binary>> = message |> Base.decode16!()

    category = decode_wake_vortex_category(type_code, category)
    callsign = callsign |> decode_callsign()

    %Message.AircraftIdentification{
      category: category,
      callsign: callsign
    }
  end

  defp decode_wake_vortex_category(type_code, _) when type_code == 1 do
    "Reserved"
  end

  defp decode_wake_vortex_category(_, category) when category == 0 do
    "No category information"
  end

  defp decode_wake_vortex_category(type_code, category) when type_code == 2 do
    case category do
      1 -> "Surface emergency vehicle"
      3 -> "Surface service vehicle"
      x when x in 4..7 -> "Ground obstruction"
    end
  end

  defp decode_wake_vortex_category(type_code, category) when type_code == 3 do
    case category do
      1 -> "Glider, sailplane"
      2 -> "Lighter-than-air"
      3 -> "Parachutist, skydiver"
      4 -> "Ultralight, hang-glider, paraglider"
      5 -> "Reserved"
      6 -> "Unmanned aerial vehicle"
      7 -> "Space or transatmospheric vehicle"
    end
  end

  defp decode_wake_vortex_category(type_code, category) when type_code == 4 do
    case category do
      1 -> "Light (less than 7000 kg)"
      2 -> "Medium 1 (between 7000kg and 34000kg)"
      3 -> "Medium 2 (between 34000kn and 136000kg)"
      4 -> "High vortex aircraft"
      5 -> "Heavy (larger than 136000kg)"
      6 -> "High performance (>5g acceleration) and high speed (>400kt)"
      7 -> "Rotorcraft"
    end
  end

  defp decode_callsign(callsign) do
    <<c1::size(6), c2::size(6), c3::size(6), c4::size(6), c5::size(6), c6::size(6), c7::size(6),
      c8::size(6)>> = callsign

    [
      get_ascii_code(c1),
      get_ascii_code(c2),
      get_ascii_code(c3),
      get_ascii_code(c4),
      get_ascii_code(c5),
      get_ascii_code(c6),
      get_ascii_code(c7),
      get_ascii_code(c8)
    ]
    |> List.to_string()
  end

  defp get_ascii_code(six_bit) do
    case six_bit do
      x when x in 1..26 -> six_bit + 64
      _ -> six_bit
    end
  end
end
