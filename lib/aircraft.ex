defmodule Aircraft do
  defstruct [
    :icao,
    :capability,
    :category,
    :callsign,
    :latitude,
    :longitude,
    :ground_speed,
    :airspeed,
    :vertical_rate,
    :is_aloft,
    :magnetic_heading,
    :ground_track_angle,
    :last_position_message
  ]

  def new_message(aircraft, message) when is_struct(message, Message.AircraftIdentification) do
    %Aircraft{
      aircraft
      | category: message.category,
        callsign: message.callsign
    }
  end

  def new_message(aircraft, message) when is_struct(message, Message.AirborneVelocity) do
    %Aircraft{
      aircraft
      | vertical_rate: message.vertical_rate
    }
    |> handle_velocity(message.sub_message)
  end

  def new_message(aircraft, message) when is_struct(message, Message.AirbornePosition) do
    aircraft |> handle_position(message) |> Map.put(:is_aloft, true)
  end

  def new_message(aircraft, message) when is_struct(message, Message.SurfacePosition) do
    # haven't implemented because I am primarily interested in flying aircraft
    # Due to location, I highly doubt I get any surface position messages.
    aircraft |> Map.put(:is_aloft, false)
  end

  def new_message(aircraft, message) when is_struct(message, Message.OperationStatus) do
    aircraft
  end

  def new_message(aircraft, _) do
    aircraft
  end

  defp handle_velocity(aircraft, velocity_message)
       when is_struct(velocity_message, Message.AirborneVelocity.GroundSpeed) do
    %Aircraft{
      aircraft
      | ground_speed: velocity_message.ground_speed,
        ground_track_angle: velocity_message.ground_track_angle
    }
  end

  defp handle_velocity(aircraft, velocity_message)
       when is_struct(velocity_message, Message.AirborneVelocity.Airspeed) do
    %Aircraft{
      aircraft
      | magnetic_heading: velocity_message.magnetic_heading,
        airspeed: velocity_message.airspeed
    }
  end

  defp handle_position(aircraft, pos_message)
       when aircraft.latitude != nil and aircraft.longitude != nil do
    # Locally unambiguous position decoding using previous position as a hint
    lat_cpr = pos_message.encoded_latitude / :math.pow(2, 17)
    lon_cpr = pos_message.encoded_longitude / :math.pow(2, 17)

    lat_zone_size = 360 / (4 * 15 - pos_message.cpr_format)

    lat_zone =
      :math.floor(aircraft.latitude / lat_zone_size) +
        :math.floor(
          mod(aircraft.latitude, lat_zone_size) / lat_zone_size -
            lat_cpr + 1 / 2
        )

    lat = lat_zone_size * (lat_zone + lat_cpr)

    nl_lat = calc_lon_zone_number(lat)
    lon_zone_size = 360 / max(nl_lat - pos_message.cpr_format, 1)

    lon_zone =
      :math.floor(aircraft.longitude / lon_zone_size) +
        :math.floor(
          mod(aircraft.longitude, lon_zone_size) / lon_zone_size - lon_cpr +
            1 / 2
        )

    lon = lon_zone_size * (lon_zone + lon_cpr)

    %Aircraft{
      aircraft
      | latitude: lat |> Float.round(7),
        longitude: lon |> Float.round(7),
        last_position_message: pos_message
    }
  end

  defp handle_position(aircraft, pos_message)
       when aircraft.last_position_message == nil or
              aircraft.last_position_message.cpr_format == pos_message.cpr_format or
              aircraft.last_position_message.cpr_format == pos_message.cpr_format do
    # We don't have enough information for position decoding
    %Aircraft{aircraft | last_position_message: pos_message}
  end

  defp handle_position(aircraft, pos_message) when pos_message.cpr_format == 0 do
    # Globally unambiguous position decoding using an odd message and an even message together

    lat_cpr_even = pos_message.encoded_latitude / :math.pow(2, 17)
    lon_cpr_even = pos_message.encoded_longitude / :math.pow(2, 17)
    lat_cpr_odd = aircraft.last_position_message.encoded_latitude / :math.pow(2, 17)
    lon_cpr_odd = aircraft.last_position_message.encoded_longitude / :math.pow(2, 17)

    lat = calc_lat(lat_cpr_even, lat_cpr_odd, :even)
    lon = calc_lon(lon_cpr_even, lon_cpr_odd, lat, :even)

    %Aircraft{
      latitude: Float.round(lat, 7),
      longitude: Float.round(lon, 7),
      last_position_message: pos_message
    }
  end

  defp handle_position(aircraft, pos_message) when pos_message.cpr_format == 1 do
    # Globally unambiguous position decoding using an odd message and an even message together

    lat_cpr_even = aircraft.last_position_message.encoded_latitude / :math.pow(2, 17)
    lon_cpr_even = aircraft.last_position_message.encoded_longitude / :math.pow(2, 17)
    lat_cpr_odd = pos_message.encoded_latitude / :math.pow(2, 17)
    lon_cpr_odd = pos_message.encoded_longitude / :math.pow(2, 17)

    lat = calc_lat(lat_cpr_even, lat_cpr_odd, :odd)
    lon = calc_lon(lon_cpr_even, lon_cpr_odd, lat, :odd)

    %Aircraft{
      latitude: Float.round(lat, 7),
      longitude: Float.round(lon, 7),
      last_position_message: pos_message
    }
  end

  defp calc_lat(lat_even, lat_odd, even_odd_flag) do
    lat_index = :math.floor(59 * lat_even - 60 * lat_odd + 1 / 2)
    lat_even = 360 / (4 * 15) * (mod(lat_index, 60) + lat_even)
    lat_odd = 360 / (4 * 15 - 1) * (mod(lat_index, 59) + lat_odd)

    lat_even =
      case lat_even do
        x when x >= 270 -> lat_even - 360
        _ -> lat_even
      end

    lat_odd =
      case lat_odd do
        x when x >= 270 -> lat_odd - 360
        _ -> lat_odd
      end

    nl_lat_even = calc_lon_zone_number(lat_even)
    nl_lat_odd = calc_lon_zone_number(lat_odd)

    case nl_lat_even == nl_lat_odd do
      true ->
        case even_odd_flag do
          :even -> lat_even
          :odd -> lat_odd
        end

      false ->
        0
    end
  end

  defp calc_lon(lon_even, lon_odd, lat, even_odd_flag) do
    nl_lat = calc_lon_zone_number(lat)
    m = :math.floor(lon_even * (nl_lat - 1) - lon_odd * nl_lat + 1 / 2)

    n =
      case even_odd_flag do
        :even -> max(nl_lat, 1)
        :odd -> max(nl_lat - 1, 1)
      end

    lon_cpr =
      case even_odd_flag do
        :even -> lon_even
        :odd -> lon_odd
      end

    lon = 360 / n * (mod(m, n) + lon_cpr)

    case lon do
      x when x >= 180 -> lon - 360
      _ -> lon
    end
  end

  defp calc_lon_zone_number(lat) do
    x_num = 1 - :math.cos(:math.pi() / 30)
    x_denom = :math.pow(:math.cos(:math.pi() / 180 * lat), 2)
    x = 1 - x_num / x_denom

    :math.floor(2 * :math.pi() / :math.acos(x))
  end

  defp mod(x, y) do
    x - y * :math.floor(x / y)
  end
end
