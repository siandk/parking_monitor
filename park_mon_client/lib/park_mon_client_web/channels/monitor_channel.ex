defmodule ParkMonClientWeb.MonitorChannel do
  alias ParkMonClient.UpdaterSupervisor
  alias ParkMon.Helper
  use Phoenix.Channel
  require Logger

  def join("room:" <> monitor_name, _params, socket) do
    Logger.info("Joined room: room:" <> monitor_name)
    case UpdaterSupervisor.add_updater(monitor_name) do
      {:ok, _} -> Logger.info("Client updater started")
      {:error, _} -> Logger.warn("Atom not found")
    end
    {:ok, socket}
  end
  def handle_in("occupied", reply, socket) do
    push(socket, "occupied", reply.msg)
    {:noreply, socket}
  end
  def handle_in("kill", %{"body" => body}, socket) do
    with {:ok, monitor} <- Helper.string_to_atom(body)
    do
      GenServer.cast(monitor, :kill)
      {:noreply, socket}
    else
      {:error, _} -> {:noreply, socket}
    end
  end
end
