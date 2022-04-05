defmodule Duper.Hasher.Supervisor do
  use DynamicSupervisor

  alias Duper.Hasher.Worker

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_worker() do
    DynamicSupervisor.start_child(__MODULE__, Worker)
  end
end
