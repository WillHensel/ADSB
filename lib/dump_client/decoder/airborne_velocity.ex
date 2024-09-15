defmodule DumpClient.Decoder.AirborneVelocity do
  def decode(message) do
    <<type_code::size(5), sub_type::size(3), intent_change_flag::size(1),
      ifr_capability_flag::size(1), nav_uncertainty::size(3), sub_type_specific::size(22),
      source_bit_vertical_rate::size(1), sign_bit_vertical_rate::size(1), vertical_rate::size(9),
      _::size(2), sign_bit_gnss_baro_diff::size(1),
      gnss_baro_diff::size(7)>> = message |> Base.decode16!()

    sub_types = %{
      1 => &decode_ground_speed/2,
      2 => &decode_ground_speed/2,
      3 => &decode_airspeed/2,
      4 => &decode_airspeed/2
    }

    # ft/min
    vertical_rate =
      case sign_bit_vertical_rate do
        0 -> 64 * (vertical_rate - 1)
        1 -> -64 * (vertical_rate - 1)
      end

    vertical_rate_src =
      case source_bit_vertical_rate do
        0 -> "GNSS"
        1 -> "Barometer"
      end

    # Negative value indicates that GNSS is below barometer altitude
    # ft

    gnss_baro_diff = calc_baro_diff(gnss_baro_diff, sign_bit_gnss_baro_diff)

    %Message.AirborneVelocity{
      type_code: type_code,
      sub_type: sub_type,
      intent_change_flag: intent_change_flag,
      ifr_capability_flag: ifr_capability_flag,
      nav_uncertainty: nav_uncertainty,
      sub_message: sub_types[sub_type].(sub_type, sub_type_specific),
      vertical_rate_src: vertical_rate_src,
      vertical_rate: vertical_rate,
      gnss_baro_diff: gnss_baro_diff
    }
  end

  defp decode_ground_speed(sub_type, message) do
    <<direction_east_west::size(1), east_west_velocity::size(10), direction_north_south::size(1),
      north_south_velocity::size(10)>> = <<message::22>>

    # Sub-type 2 is for supersonic and has a speed resolution of 4kt instead of 1kt like for subsonic
    # Currently that subtype wouldn't be in use, but I've supported it anyway

    vx =
      case direction_east_west do
        0 -> east_west_velocity - 1
        1 -> -1 * (east_west_velocity - 1)
      end

    vy =
      case direction_north_south do
        0 -> north_south_velocity - 1
        1 -> -1 * (north_south_velocity - 1)
      end

    # supersonic case
    if sub_type == 2 do
      ^vx = vx * 4
      ^vy = vy * 4
    end

    # knots
    ground_speed = :math.sqrt(:math.pow(vx, 2) + :math.pow(vy, 2))

    # degrees
    ground_track_angle = calc_ground_track_angle(vx, vy) |> normalize_ground_track_angle()

    %Message.AirborneVelocity.GroundSpeed{
      ground_speed: Float.round(ground_speed, 2),
      ground_track_angle: Float.round(ground_track_angle, 2)
    }
  end

  defp decode_airspeed(sub_type, message) do
    # An airspeed message only is sent in the event that position cannot be determined by GNSS so sub-type 3 and 4 are rare.
    <<status_mag_heading::size(1), mag_heading::size(10), airspeed_type_flag::size(1),
      airspeed::size(10)>> = <<message::22>>

    # degrees
    mag_heading = mag_heading * (360 / 1024)

    # knots
    airspeed =
      case sub_type do
        3 -> airspeed - 1
        4 -> 4 * (airspeed - 1)
      end

    type =
      case airspeed_type_flag do
        0 -> "Indicated"
        1 -> "True"
      end

    %Message.AirborneVelocity.Airspeed{
      magnetic_heading: Float.round(mag_heading, 2),
      airspeed: airspeed,
      airspeed_type: type
    }
  end

  defp calc_baro_diff(raw_baro_diff, _) when raw_baro_diff == 0 do
    0
  end

  defp calc_baro_diff(raw_baro_diff, diff_sign) do
    case diff_sign do
      0 -> (raw_baro_diff - 1) * 25
      1 -> -1 * (raw_baro_diff - 1) * 25
    end
  end

  defp calc_ground_track_angle(vx, vy) do
    normalize_ground_track_angle(:math.atan2(vx, vy) * 360 / (2 * :math.pi()))
  end

  defp normalize_ground_track_angle(angle) when angle < 0 do
    angle - 360 * :math.floor(angle / 360)
  end

  defp normalize_ground_track_angle(angle) do
    angle
  end
end
