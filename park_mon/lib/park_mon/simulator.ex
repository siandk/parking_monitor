defmodule ParkMon.Simulator do
  alias ParkMon.Helper
  use GenServer


  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(_) do
    :timer.send_interval(3000, :park)
    {:ok, []}
  end

  def handle_info(:park, list) do
    {:noreply, do_parking(list)}
  end

  defp do_parking(list) do
    chance = Enum.random(0..100)
    cond do
      chance >= 45 -> enter(list)
      chance < 45 -> leave(list)
    end
  end

  defp enter(list) do
    {pid, license_plate} = random_new()
    with {:ok, _} <- Helper.pid_exists(pid),
         {:ok, _} <- GenServer.call(pid, {:enter, license_plate})
    do
      list ++ [{pid, license_plate}]
    else
      _ -> list
    end
  end
  defp leave(list) when length(list) > 0 do
    {pid, license_plate} = Enum.random(list)
    with {:ok, _} <- Helper.pid_exists(pid),
         {:ok, _} <- GenServer.call(pid, {:leave, license_plate})
    do
      Enum.filter(list, fn {_, plate} -> plate != license_plate end)
    else
      _ -> list
    end
  end
  defp leave([]), do: []

  # Gets a random monitor from a random area and adds a new 'license plate'
  defp random_new() do
    {pid, _, _, _} =
      [:east, :northeast, :southeast, :west, :northwest, :southwest, :south, :north, :center]
      |> Enum.random()
      |> Supervisor.which_children()
      |> Enum.random()
    {pid, UUID.uuid4()}
  end
end
