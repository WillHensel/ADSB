defmodule DumpClient.Decoder.AirbornePosition do
  def decode(message) do
    <<type_code::size(5), surveillance_status::size(2), signal_antenna_flag::size(1),
      encoded_altitude::size(12), time::size(1), cpr_format::size(1), encoded_latitude::size(17),
      encoded_longitude::size(17)>> = message |> Base.decode16!()

    %Message.AirbornePosition{}
  end
end
