defmodule AircraftTest do
  use ExUnit.Case

  test "AirbornePosition globally unambiguous" do
    ac = %Aircraft{}

    ac =
      Aircraft.new_message(ac, %Message.AirbornePosition{
        cpr_format: 1,
        encoded_latitude: 74158,
        encoded_longitude: 50194
      })

    assert ac.latitude == nil
    assert ac.longitude == nil
    assert ac.last_position_message != nil
    assert ac.is_aloft == true

    ac =
      Aircraft.new_message(ac, %Message.AirbornePosition{
        cpr_format: 0,
        encoded_latitude: 93000,
        encoded_longitude: 51372
      })

    assert ac.latitude == 52.2572021
    assert ac.longitude == 3.9193726
  end

  test "AirbornePosition locally unambiguous" do
    ac = %Aircraft{latitude: 52.258, longitude: 3.918}

    ac =
      Aircraft.new_message(ac, %Message.AirbornePosition{
        cpr_format: 0,
        encoded_latitude: 93000,
        encoded_longitude: 51372
      })

    assert ac.latitude == 52.2572021
    assert ac.longitude == 3.9193726
  end
end
