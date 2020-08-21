defmodule PubsubtestWeb.RedirectToGameInProgress do
  @moduledoc """
  Redirects any request to running game saved in session cookie.
  It effectively restricts player in game to single endpoint.
  """

  import PubsubtestWeb.SessionHelper, only: [get_game: 1]
  import Pubsubtest.GameUrl, only: [url_for_type: 2]

  @behaviour Plug

  def init(default), do: default

  def call(conn, _opts) do
    running_game = get_game(conn)

    if is_nil(running_game) do
      conn
    else
      {game_id, game_type} = running_game
      valid_url = url_for_type(game_type, game_id)
      redirect_when_not_game_url(conn, valid_url)
    end
  end

  defp redirect_when_not_game_url(conn = %Plug.Conn{request_path: valid_url}, valid_url) do
    conn
  end

  defp redirect_when_not_game_url(conn, valid_url) do
    Phoenix.Controller.redirect(conn, to: valid_url)
    |> Plug.Conn.halt()
  end
end
