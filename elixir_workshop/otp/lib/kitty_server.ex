defmodule KittyServer do
  defmodule Cat do
    defstruct name: nil, color: :black, description: nil
  end

  # ------------------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------------------

  def start_link() do
    spawn_link(&init/0)
  end

  # Synchronous call
  def order_cat(pid, name, color, description) do
    ref = Process.monitor(pid)
    send(pid, {self(), ref, {:order, name, color, description}})

    receive do
      {^ref, %Cat{} = cat} ->
        Process.demonitor(ref, [:flush])
        cat

      {:DOWN, ^ref, :process, ^pid, reason} ->
        throw(reason)
    after
      5000 ->
        throw(:timeout)
    end
  end

  # Synchronous call
  def close_shop(pid) do
    ref = Process.monitor(pid)
    send(pid, {self(), ref, :terminate})

    receive do
      {^ref, :ok} ->
        Process.demonitor(ref, [:flush])
        :ok

      {:DOWN, ^ref, :process, ^pid, reasion} ->
        throw(reasion)
    after
      5000 ->
        throw(:timeout)
    end
  end

  # Asynchronous call
  def return_cat(pid, %Cat{} = cat) do
    send(pid, {:return, cat})
    :ok
  end

  # ------------------------------------------------------------------------------
  # Server functions
  # ------------------------------------------------------------------------------

  def init() do
    loop([])
  end

  def loop(cats) do
    receive do
      {pid, ref, {:order, name, color, description}} ->
        case cats do
          [] ->
            send(pid, {ref, make_cat(name, color, description)})
            loop(cats)

          [cat | tail] ->
            send(pid, {ref, cat})
            loop(tail)
        end

      {:return, %Cat{} = cat} ->
        loop([cat | cats])

      {pid, ref, :terminate} ->
        send(pid, {ref, :ok})
        terminate(cats)

      unknown ->
        IO.inspect("Unknown message: #{unknown}")
        loop(cats)
    end
  end

  defp make_cat(name, color, description) do
    %Cat{name: name, color: color, description: description}
  end

  def terminate(cats) do
    for cat <- cats, do: IO.inspect("#{cat.name} was set free.")
    :ok
  end
end
