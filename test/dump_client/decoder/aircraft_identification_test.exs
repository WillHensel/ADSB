defmodule DumpClient.Decoder.AircraftIdentificationTest do
  use ExUnit.Case

  test "decode" do
    decoded_msg = DumpClient.Decoder.AircraftIdentification.decode("202CC371C32CE0")

    assert decoded_msg.category == "No category information"
    assert decoded_msg.callsign == "KLM1023 "
  end
end
