defmodule Duper.Application do
  @moduledoc false

  use Application

  alias Duper.{Storage, PathFinder}

  @impl true
  def start(_type, _args) do
    children = [
      Storage,
      {PathFinder, "."}
    ]

    opts = [strategy: :one_for_one, name: Duper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
