defmodule PubsubtestWeb.SessionHelper do
  def get_player_id(conn) do
    Plug.Conn.get_session(conn, :player_id)
  end

  def has_player_id(conn) do
    get_player_id(conn) != nil
  end

  def get_game(conn) do
    Plug.Conn.get_session(conn, :running_game)
  end

  def remove_game_id(conn) do
    Plug.Conn.delete_session(conn, :running_game)
  end

  def assign_game_id(conn, game_id, game_type) do
    Plug.Conn.put_session(conn, :running_game, {game_id, game_type})
  end

  def assign_player_id(conn) do
    Plug.Conn.put_session(conn, :player_id, UUID.uuid4())
  end
end
