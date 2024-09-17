defmodule Adsb.Aircraft.Handler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Takes a decoded ADSB message and either updates an existing aircraft entry or
  creates a new one with the information in the message.
  """
  def handle_message(message) do
    GenServer.cast(__MODULE__, {:handle_message, message})
  end

  def get_aircraft() do
    GenServer.call(__MODULE__, {:get_aircraft})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting Adsb.AircraftHandler")
    aircraft = %{}

    {:ok, msg_listener} = Dump.Listener.start(&__MODULE__.handle_message/1)
    Dump.Listener.listen(msg_listener)

    {:ok, {aircraft, msg_listener}}
  end

  @impl GenServer
  def handle_cast({:handle_message, message}, {aircraft, msg_listener}) do
    entry =
      case Map.fetch(aircraft, message.icao) do
        {:ok, val} -> val
        :error -> %Adsb.Aircraft{icao: message.icao}
      end

    entry =
      %Adsb.Aircraft{entry | capability: message.capability}
      |> Adsb.Aircraft.new_message(message.message)

    aircraft = Map.put(aircraft, message.icao, entry)

    {:noreply, {aircraft, msg_listener}}
  end

  @impl GenServer
  def handle_call({:get_aircraft}, _, {aircraft, msg_listener}) do
    {:reply, aircraft, {aircraft, msg_listener}}
  end
end
