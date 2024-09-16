defmodule DumpClient.Decoder.SurfacePositionTest do
  use ExUnit.Case

  test "decode even" do
    decoded = DumpClient.Decoder.SurfacePosition.decode("3AAB238733C8CD")

    assert decoded.type_code == 7
    assert decoded.cpr_format == 0
    assert decoded.encoded_latitude == 115_609
    assert decoded.encoded_longitude == 116_941
  end

  test "decode odd" do
    decoded = DumpClient.Decoder.SurfacePosition.decode("3A8A35323FAEBD")

    assert decoded.type_code == 7
    assert decoded.cpr_format == 1
    assert decoded.encoded_latitude == 39199
    assert decoded.encoded_longitude == 110_269
  end

  test "decode ground_track and movement" do
    decoded = DumpClient.Decoder.SurfacePosition.decode("3A9A153237AEF0")

    assert decoded.ground_track == 92.8125
    assert decoded.movement == 17
  end
end
