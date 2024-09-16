defmodule DumpClient.Listener do
  # TODO in its current state, does this really need to be its own process? All it does is fire once, which
  # creates a new process, and then idles indefinitely. Possibly needs to be more sophisticated in the future?
  use GenServer

  def start(callback) do
    GenServer.start(__MODULE__, callback)
  end

  def listen(listener) do
    GenServer.cast(listener, {:listen})
  end

  @impl GenServer
  def init(callback) do
    # TODO setup socket and listener in handle_continue
    {:ok, message_handler} = DumpClient.MessageDecoder.start()

    {:ok, socket} =
      :gen_tcp.connect({192, 168, 1, 121}, 30002, [:binary, :inet, active: false, packet: :line])

    {:ok, {socket, message_handler, callback}}
  end

  @impl GenServer
  def handle_cast({:listen}, {socket, message_handler, callback}) do
    spawn(fn -> handle_socket_messages(socket, message_handler, callback) end)

    {:noreply, {socket, message_handler, callback}}
  end

  defp handle_socket_messages(socket, message_handler, callback) do
    {:ok, message} = :gen_tcp.recv(socket, 0)

    decoded = DumpClient.MessageDecoder.decode_message(message_handler, message)

    if decoded != nil do
      callback.(decoded)
    end

    handle_socket_messages(socket, message_handler, callback)
  end
end
