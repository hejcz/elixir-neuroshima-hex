defmodule PubsubtestWeb.TicTacToeChannel do
  use Phoenix.Channel

  def join("room:tictactoe:" <> game_id, _message, socket) do
    socket_game_id = socket.assigns[:game_id]

    if socket_game_id != game_id do
      {:error, %{reason: "Game id does not match"}}
    else
      send(self(), :after_join)
      {:ok, socket}
    end
  end

  def join(_private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    broadcast!(socket, "event_joined", TicTacToe.Game.representation(socket.assigns[:game_pid]))
    {:noreply, socket}
  end

  def handle_in("start", _params, socket) do
    if TicTacToe.Game.start(socket.assigns[:game_pid], socket.assigns[:player_id]) == :ok do
      broadcast!(socket, "start", %{})
    end

    {:noreply, socket}
  end

  def handle_in("quit", _params, socket) do
    if TicTacToe.Game.quit(socket.assigns[:game_pid], socket.assigns[:player_id]) == :ok do
      broadcast!(socket, "quit", %{"player_name" => socket.assigns[:player_id]})
    end

    {:noreply, socket}
  end

  def handle_in("act", _params = %{"name" => "draw", "position" => position}, socket) do
    drawing_result =
      TicTacToe.Game.draw(socket.assigns[:game_pid], socket.assigns[:player_id], position)

    IO.inspect(drawing_result)
    handle_draw(socket, drawing_result)
    {:noreply, socket}
  end

  defp handle_draw(_socket, {:error, _}) do
  end

  defp handle_draw(socket, board) do
    broadcast!(socket, "act", board)
  end
end
