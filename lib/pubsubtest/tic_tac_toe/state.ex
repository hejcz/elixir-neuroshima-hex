defmodule TicTacToe.State do
  alias __MODULE__

  @full_lines [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9],
    [1, 5, 9],
    [3, 5, 7]
  ]

  defstruct id: nil,
            crosses: MapSet.new(),
            circles: MapSet.new(),
            has_left: MapSet.new(),
            players: [],
            current_player_index: 0,
            started: false

  def new(id) do
    %State{id: id}
  end

  def count_players(game) do
    Enum.count(game.players) - Enum.count(game.has_left)
  end

  def join(game, username) do
    count = count_players(game)

    case count do
      0 ->
        {:ok, %State{game | players: [{username, :cross}]}}

      1 ->
        {:ok, %State{game | players: game.players ++ [{username, :circle}]}}

      _ ->
        if Enum.any?(game.players, fn {name, _} -> name == username end) do
          {:ok, game}
        else
          {:error, "Can't join"}
        end
    end
  end

  def start(state, username) do
    case state do
      %State{players: [{^username, _} | _], started: false} ->
        if count_players(state) == 2 and Enum.empty?(state.has_left) do
          {:ok, %State{state | started: true}}
        else
          {:error, "not enough players"}
        end

      _ ->
        {:error, "only first player can start the game"}
    end
  end

  defp position_is_occupied(state, position) do
    is_occupied =
      MapSet.member?(state.crosses, position) or MapSet.member?(state.crosses, position)

    if is_occupied do
      {:error, "occupied position"}
    else
      false
    end
  end

  defp is_current_player(state, username) do
    current_player_name = player_name(state, state.current_player_index)

    if current_player_name != username do
      {:error, "not your turn"}
    else
      true
    end
  end

  defp game_is_finished(state) do
    if game_finished?(state) do
      {:error, "game has finished"}
    else
      false
    end
  end

  defp game_finished?(state) do
    determine_winner(state) != nil or Enum.count(state.circles) + Enum.count(state.crosses) == 9
  end

  def draw(game = %State{started: true}, username, position) do
    with false <- position_is_occupied(game, position),
         true <- is_current_player(game, username),
         false <- game_is_finished(game) do
      mark = current_player_mark(game)

      case mark do
        :circle ->
          {:ok,
           %State{
             game
             | circles: MapSet.put(game.circles, position),
               current_player_index: rem(game.current_player_index + 1, 2)
           }}

        :cross ->
          {:ok,
           %State{
             game
             | crosses: MapSet.put(game.crosses, position),
               current_player_index: rem(game.current_player_index + 1, 2)
           }}
      end
    else
      err -> err
    end
  end

  def draw(_, _, _) do
    {:error, "game hasn't started yet"}
  end

  def quit(state = %State{started: false}, username) do
    do_quit(state, username)
  end

  def quit(state, username) do
    if game_finished?(state) do
      do_quit(state, username)
    else
      {:error, "Game already started"}
    end
  end

  defp do_quit(state, username) do
    {:ok, %State{state | has_left: MapSet.put(state.has_left, username)}}
  end

  defp determine_winner(game) do
    cond do
      contains_full_line?(game.crosses) -> player_name(game, 0)
      contains_full_line?(game.circles) -> player_name(game, 1)
      true -> nil
    end
  end

  def has_left(state, username) do
    Enum.any?(state.has_left, fn nick -> nick == username end)
  end

  def representation(game) do
    board =
      for n <- 1..9 do
        cond do
          MapSet.member?(game.circles, n) -> "o"
          MapSet.member?(game.crosses, n) -> "x"
          true -> " "
        end
      end

    winner = determine_winner(game)

    %{
      :board => board,
      :current_player_name => player_name(game, game.current_player_index),
      :finished => winner != nil,
      :winner => winner
    }
  end

  defp contains_full_line?(positions) do
    Enum.any?(@full_lines, fn line -> Enum.all?(line, &MapSet.member?(positions, &1)) end)
  end

  defp player_name(game, index) do
    case player(game, index) do
      {name, _} -> name
      _ -> nil
    end
  end

  defp current_player_mark(game) do
    case player(game, game.current_player_index) do
      {_, mark} -> mark
      _ -> nil
    end
  end

  defp player(game, index) do
    Enum.at(game.players, index)
  end
end
