defmodule PubsubtestWeb.PageController do
  use PubsubtestWeb, :controller

  defmodule OpenGame do
    defstruct type: nil, name: nil, all_seats: 8, free_seats: 4, id: nil
  end

  def index(conn, _params) do
    {:ok, open_games} = Pubsubtest.GameManager.all_open_games(Pubsubtest.GameManager)

    render(conn, "index.html",
      games:
        Enum.map(open_games, fn game ->
          %OpenGame{type: game.type, name: game.name, id: game.id}
        end)
    )
  end

  def new_game(conn, _params = %{"game" => %{"name" => name, "type" => type}}) do
    new_game = Pubsubtest.GameManager.add_game(Pubsubtest.GameManager, name, String.to_atom(type))
    handle_new_game(conn, new_game, name, type)
  end

  defp handle_new_game(conn, {:error, _}, _name, _type) do
    redirect(conn, to: "/")
  end

  defp handle_new_game(conn, {:ok, pid, game_id}, _, type) when is_pid(pid) do
    redirect(conn, to: Pubsubtest.GameUrl.url_for_type(type, game_id))
  end
end
