defmodule PubsubtestWeb.CartographersController do
  use PubsubtestWeb, :controller

  def index(conn, %{"game_id" => game_id}) do
    game_pid = Pubsubtest.GameManager.find(Pubsubtest.GameManager, game_id)
    player_id = PubsubtestWeb.SessionHelper.get_player_id(conn)

    game_from_cookie = PubsubtestWeb.SessionHelper.get_game(conn)

    if game_pid == nil or not Process.alive?(game_pid) or
         TicTacToe.Game.has_left(game_pid, player_id) do
      case game_from_cookie do
        {^game_id, _} -> conn |> PubsubtestWeb.SessionHelper.remove_game_id()
        _ -> conn
      end
      |> redirect(to: "/")
    else
      case Cartographers.Game.join(game_pid, player_id) do
        :ok ->
          token =
            Phoenix.Token.sign(conn, "salt", %{
              "game_id" => game_id,
              "player_id" => player_id,
              "game_type" => :cartographers,
              "game_pid" => game_pid
            })

          conn
          |> PubsubtestWeb.SessionHelper.assign_game_id(game_id, :cartographers)
          |> render("cartographers.html", game_id: game_id, token: token)

        {:error, _} ->
          redirect(conn, to: "/")
      end
    end
  end
end
