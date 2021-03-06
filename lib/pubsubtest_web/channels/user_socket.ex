defmodule PubsubtestWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:tictactoe:*", PubsubtestWeb.TicTacToeChannel
  channel "room:cartographers:*", PubsubtestWeb.CartographersChannel
  channel "room:lobby", PubsubtestWeb.RoomChannel

  @impl true
  def connect(_params = %{"token" => token}, socket, _connect_info) do
    verified_token = Phoenix.Token.verify(socket, "salt", token)

    case verified_token do
      {:ok,
       %{
         "game_id" => game_id,
         "player_id" => player_id,
         "game_type" => game_type,
         "game_pid" => game_pid
       }} ->
        {:ok,
         socket
         |> assign(
           game_id: game_id,
           player_id: player_id,
           game_type: game_type,
           game_pid: game_pid
         )}

      _ ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PubsubtestWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
