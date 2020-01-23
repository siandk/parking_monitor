defmodule ParkMon.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ParkMon.Store, [strategy: :one_for_one]},
      %{id: :east, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :east]}},
      %{id: :northeast, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :northeast]}},
      %{id: :southeast, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :southeast]}},
      %{id: :west, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :west]}},
      %{id: :northwest, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :northwest]}},
      %{id: :southwest, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :southwest]}},
      %{id: :north, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :north]}},
      %{id: :south, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :south]}},
      %{id: :center, start: {ParkMon.AreaSupervisor, :start_link, [strategy: :one_for_one, name: :center]}},
      {ParkMon.SimulatorSupervisor, [strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one, name: ParkMon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
