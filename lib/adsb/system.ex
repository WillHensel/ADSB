defmodule Adsb.System do
  def start_link do
    Supervisor.start_link([AircraftHandler], strategy: :one_for_one)
  end
end
