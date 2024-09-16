defmodule Message.AirbornePosition do
  defstruct [
    :type_code,
    :surveillance_status,
    :altitude,
    :cpr_format,
    :encoded_latitude,
    :encoded_longitude
  ]
end
