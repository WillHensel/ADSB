defmodule DumpClient.Decoder.AirborneVelocityTest do
  use ExUnit.Case

  test "decode ground speed sub-type" do
    decoded_msg =
      DumpClient.Decoder.AirborneVelocity.decode("99440994083817")

    assert decoded_msg.type_code == 19
    assert decoded_msg.sub_type == 1
    assert decoded_msg.vertical_rate_src == "GNSS"
    assert decoded_msg.vertical_rate == -832
    assert decoded_msg.gnss_baro_diff == 550

    assert decoded_msg.sub_message.ground_speed == 159.20
    assert decoded_msg.sub_message.ground_track_angle == 182.88
  end

  test "decode airspeed sub-type" do
    # Message is sub-type 3 for subsonic aircraft
    decoded_msg = DumpClient.Decoder.AirborneVelocity.decode("9B06B6AF189400")

    assert decoded_msg.type_code == 19
    assert decoded_msg.sub_type == 3
    assert decoded_msg.vertical_rate_src == "Barometer"
    assert decoded_msg.vertical_rate == -2304

    # TODO 0 has two meanings, either the difference is actually 0 or the information is not available
    assert decoded_msg.gnss_baro_diff == 0

    assert decoded_msg.sub_message.magnetic_heading == 243.98
    assert decoded_msg.sub_message.airspeed == 375
    assert decoded_msg.sub_message.airspeed_type == "True"
  end
end
