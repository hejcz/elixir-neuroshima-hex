defmodule PubsubtestWeb.AssignPlayerIdIfMissing do
  @moduledoc """
  Assigns session id to a visitor.
  """

  import PubsubtestWeb.SessionHelper, only: [has_player_id: 1, assign_player_id: 1]

  def init(default), do: default

  def call(conn = %Plug.Conn{request_path: "/"}, _opts) do
    conn
  end

  def call(conn, _opts) do
    if !has_player_id(conn) do
      assign_player_id(conn)
    else
      conn
    end
  end
end
