defmodule AircraftHandler do
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

  @impl GenServer
  def init(_) do
    IO.puts("Starting AircraftHandler")
    aircraft = %{}

    {:ok, msg_listener} = DumpClient.Listener.start(&__MODULE__.handle_message/1)
    DumpClient.Listener.listen(msg_listener)

    {:ok, {aircraft, msg_listener}}
  end

  @impl GenServer
  def handle_cast({:handle_message, message}, {aircraft, msg_listener}) do
    entry =
      case Map.fetch(aircraft, message.icao) do
        {:ok, val} -> val
        :error -> %Aircraft{icao: message.icao}
      end

    entry =
      %Aircraft{entry | capability: message.capability}
      |> Aircraft.new_message(message.message)

    aircraft = Map.put(aircraft, message.icao, entry)

    IO.inspect(aircraft)

    {:noreply, {aircraft, msg_listener}}
  end
end
