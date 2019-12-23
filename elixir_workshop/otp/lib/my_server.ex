defmodule MyServer do
  def start(module, init_state) do
    spawn(fn -> init(module, init_state) end)
  end

  def start_link(module, init_state) do
    spawn_link(fn -> init(module, init_state) end)
  end

  def call(pid, msg) do
    ref = Process.monitor(pid)
    send(pid, {:sync, self(), ref, msg})

    receive do
      {^ref, reply} ->
        Process.demonitor(ref, [:flush])
        reply

      {:DOWN, ^ref, :process, reason} ->
        throw(reason)
    after
      5000 ->
        throw(:timeout)
    end
  end

  def cast(pid, msg) do
    send(pid, {:async, msg})
    :ok
  end

  def reply({pid, ref}, reply) do
    send(pid, {ref, reply})
  end

  defp init(module, init_state) do
    loop(module, module.init(init_state))
  end

  def loop(module, state) do
    receive do
      {:async, msg} ->
        loop(module, module.handle_cast(msg, state))

      {:sync, pid, ref, msg} ->
        loop(module, module.handle_call(msg, {pid, ref}, state))
    end
  end
end
