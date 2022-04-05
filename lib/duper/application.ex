defmodule Duper.Application do
  @moduledoc false

  use Application

  alias Duper.Hasher.Gatherer

  @impl true
  def start(_type, _args) do
    children = [
      {Gatherer, System.schedulers_online() * 2}
    ]

    opts = [strategy: :one_for_one, name: Duper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
