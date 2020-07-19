defmodule TicTacToeGame do
  use GenServer

  @winning_positions [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9],
    [1, 5, 9],
    [3, 5, 7]
  ]

  defstruct name: nil, crosses: MapSet.new(), circles: MapSet.new(), players_count: 0

  def init(init_arg) do
    {:ok, init_arg}
  end

  defp can_join?(%TicTacToeGame{players_count: 2}), do: false

  defp can_join?(_game), do: true

  def join(game, _player_id) do
    cond do
      can_join?(game) ->
        new_game = %TicTacToeGame{game | players_count: game.players_count + 1}

        if can_join?(new_game) do
          GenServer.call(Pubsubtest.GameManager, {:started, game.name})
        end

        new_game

      true ->
        game
    end
  end

  def put(game, :cross, position) do
    %TicTacToeGame{game | crosses: MapSet.put(game.crosses, position)}
  end

  def put(game, :circle, position) do
    %TicTacToeGame{game | circles: MapSet.put(game.circles, position)}
  end

  def finished?(game) do
    Enum.any?(@winning_positions, fn positions ->
      Enum.all?(positions, &MapSet.member?(game.circles, &1))
    end) or
      Enum.any?(@winning_positions, fn positions ->
        Enum.all?(positions, &MapSet.member?(game.crosses, &1))
      end)
  end
end
