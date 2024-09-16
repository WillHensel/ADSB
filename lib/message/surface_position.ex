defmodule Message.SurfacePosition do
  defstruct [
    :type_code,
    :movement,
    :ground_track,
    :cpr_format,
    :encoded_latitude,
    :encoded_longitude,
    :time
  ]
end
