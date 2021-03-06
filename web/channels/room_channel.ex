defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  alias PhoenixChat.Presence

  def join("room:lobby", _, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presences", Presence.list(socket)
    Presence.track(socket, socket.assigns.user, %{
      user: socket.assigns.user,
      online_at: :os.system_time(:milli_seconds)
    })
    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    broadcast! socket, "message:new", %{
      user: socket.assigns.user,
      body: message,
      timestamp: :os.system_time(:milli_seconds)
    }
    {:noreply, socket}
  end
end
