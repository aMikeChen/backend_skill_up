defmodule Otp.CatShop.Supervisor do
  use Supervisor

  alias Otp.CatShop

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      {CatShop, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
