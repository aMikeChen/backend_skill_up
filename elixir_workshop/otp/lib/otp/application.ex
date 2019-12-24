defmodule Otp.Application do
  use Application

  alias Otp.CatShop

  def start(_type, _args) do
    children = [
      {StackSupervisor, strategy: :one_for_one, name: StackSupervisor},
      {CatShop.Supervisor, strategy: :one_for_one, name: CatShop.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: __MODULE__)
  end
end
