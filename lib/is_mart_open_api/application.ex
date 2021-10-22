defmodule IsMartOpenApi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: IsMartOpenApi.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: IsMartOpenApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
