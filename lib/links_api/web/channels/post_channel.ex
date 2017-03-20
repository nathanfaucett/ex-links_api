defmodule LinksApi.Web.PostChannel do
  use Phoenix.Channel
  require Logger


  def join("posts", _message, socket) do
    Process.flag(:trap_exit, true)
    send(self(), {:after_join})
    {:ok, socket}
  end

  def handle_info({:after_join}, socket) do
    broadcast! socket, "user:entered", %{}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug "> leave #{inspect reason}"
    :ok
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
