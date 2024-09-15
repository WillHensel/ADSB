defmodule AircraftHandler do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  @doc """
  Takes a decoded ADSB message and either updates an existing aircraft entry or
  creates a new one with the information in the message.
  """
  def handle_message(ac_handler, message) do
    GenServer.cast(ac_handler, {:handle_message, message})
  end

  @impl GenServer
  def init(_) do
    aircraft = %{}
    {:ok, {aircraft}}
  end

  @impl GenServer
  def handle_cast({:handle_message, message}, {aircraft}) do
    entry =
      case Map.fetch(aircraft, message.icao) do
        {:ok, val} -> val
        :error -> %Aircraft{icao: message.icao}
      end

    entry = %Aircraft{entry | capability: message.capability}

    IO.inspect(entry)

    {:noreply, {aircraft}}
  end
end
