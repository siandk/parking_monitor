defmodule ParkMon.Monitor do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(state) do
    # Query ETS for entries on this parking lot,
    # in case of an unintended shutdown
    case GenServer.call(:store, {:lookup, {:monitor, state[:name]}}) do
      {:ok, []} -> {:ok, state}
      {:ok, list} -> {:ok, %{state|occupied: List.flatten(list)}}
    end
  end

  def handle_call({:enter, license_plate}, _from, monitor) do
    with {:ok, _} <- check_free(monitor),
         {:ok, _} <- GenServer.call(:store, {:create, {monitor[:name], monitor[:location], license_plate}})
    do
      {:reply, {:ok, license_plate}, update_state(:enter, monitor, license_plate)}
    else
      {:error, _} -> {:reply, {:error, nil}, monitor}
    end
  end
  def handle_call({:leave, license_plate}, _from, monitor) do
    GenServer.cast(:store, {:delete, license_plate})
    {:reply, {:ok, license_plate}, update_state(:leave, monitor, license_plate)}
  end
  def handle_call(:occupied, _from, monitor) do
    {:reply, {:ok, {monitor[:occupied], monitor[:spots]}}, monitor}
  end

  # Used for showing recovery after an unintended shutdown
  def handle_cast(:kill, _state) do
    10 / 0
  end

  defp check_free(monitor) do
    occupied = length(monitor[:occupied])
    spots = monitor[:spots]
    cond do
      occupied < spots -> {:ok, occupied - spots}
      occupied >= spots -> {:error, 0}
    end
  end

  defp update_state(:enter, monitor, license_plate) do
    %{monitor|occupied: monitor[:occupied] ++ [license_plate]}
  end
  defp update_state(:leave, monitor, license_plate) do
    %{monitor|occupied: Enum.filter(monitor[:occupied], fn parked_car -> parked_car != license_plate end)}
  end

end
