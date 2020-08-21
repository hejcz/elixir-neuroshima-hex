defmodule Pubsubtest.GameManager do
  @moduledoc """
  Module responsible for managing games. It holds list of open and started games.
  """

  use GenServer
  alias __MODULE__

  defstruct open: %{}, in_progress: %{}

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, %GameManager{}, default)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def add_game(game_manager, name, type) do
    GenServer.call(game_manager, {:add, name, type})
  end

  def find(game_manager, name) do
    GenServer.call(game_manager, {:find, name})
  end

  def start_game(game_manager, name) do
    GenServer.call(game_manager, {:started, name})
  end

  def all_open_games(game_manager) do
    GenServer.call(game_manager, :find_open)
  end

  def remove(game_manager, game_id) do
    GenServer.call(game_manager, {:remove, game_id})
  end

  @impl true
  def handle_call({:add, name, type}, _from, games) do
    cond do
      game_exists?(games, name) ->
        {:reply, {:error, :game_exists}, games}

      true ->
        id = UUID.uuid4()
        {:ok, pid} = GenServer.start(module_for_type(type), %{:id => id})

        {:reply, {:ok, pid, id},
         %GameManager{
           games
           | open:
               Map.put_new(games.open, id, %RunningGame{name: name, pid: pid, type: type, id: id})
         }}
    end
  end

  @impl true
  def handle_call({:find, id}, _from, games) do
    pid =
      [Map.get(games.open, id), Map.get(games.in_progress, id)]
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.map(& &1.pid)
      |> List.first()

    {:reply, pid, games}
  end

  @impl true
  def handle_call({:started, id}, _from, games) do
    {:reply, :ok,
     %GameManager{
       games
       | in_progress: Map.put(games.in_progress, id, Map.get(games.open, id)),
         open: Map.delete(games.open, id)
     }}
  end

  @impl true
  def handle_call(:find_open, _from, games) do
    {:reply, {:ok, Map.values(games.open)}, games}
  end

  @impl true
  def handle_call({:remove, id}, _from, games) do
    {:reply, :ok,
     %GameManager{
       games
       | in_progress: Map.delete(games.in_progress, id),
         open: Map.delete(games.open, id)
     }}
  end

  defp game_exists?(%GameManager{open: open, in_progress: in_progress}, id)
       when is_map_key(open, id) or is_map_key(in_progress, id),
       do: true

  defp game_exists?(_, _), do: false

  defp module_for_type(:tic_tac_toe), do: TicTacToe.Game

  defp module_for_type(:cartographers), do: Cartographers.Game
end
