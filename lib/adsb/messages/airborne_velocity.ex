defmodule Message.AirborneVelocity do
  defstruct [
    :type_code,
    :sub_type,
    :intent_change_flag,
    :ifr_capability_flag,
    :nav_uncertainty,
    :sub_type_message,
    :vertical_rate_src,
    :vertical_rate,
    :gnss_baro_diff,
    :sub_message
  ]
end

defmodule Message.AirborneVelocity.GroundSpeed do
  defstruct [
    :ground_speed,
    :ground_track_angle
  ]
end

defmodule Message.AirborneVelocity.Airspeed do
  defstruct [
    :magnetic_heading,
    :airspeed,
    :airspeed_type
  ]
end
