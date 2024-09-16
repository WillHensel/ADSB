defmodule DumpClient.Decoder.AirbornePositionTest do
  use ExUnit.Case

  test "even frame" do
    decoded = DumpClient.Decoder.AirbornePosition.decode("58C382D690C8AC")

    assert decoded.type_code == 11
    assert decoded.surveillance_status == "No condition"
    assert decoded.altitude == 38000
    assert decoded.cpr_format == 0
    assert decoded.encoded_latitude == 93000
    assert decoded.encoded_longitude == 51372
  end

  test "odd frame" do
    decoded = DumpClient.Decoder.AirbornePosition.decode("58C386435CC412")

    assert decoded.type_code == 11
    assert decoded.surveillance_status == "No condition"
    assert decoded.altitude == 38000
    assert decoded.cpr_format == 1
    assert decoded.encoded_latitude == 74158
    assert decoded.encoded_longitude == 50194
  end
end
