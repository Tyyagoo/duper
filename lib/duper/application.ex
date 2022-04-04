defmodule Duper.Application do
  @moduledoc false

  use Application

  alias Duper.{Storage}

  @impl true
  def start(_type, _args) do
    children = [
      Storage
    ]

    opts = [strategy: :one_for_one, name: Duper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
