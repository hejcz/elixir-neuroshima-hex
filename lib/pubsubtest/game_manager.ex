defmodule Pubsubtest.GameManager do
  use GenServer

  defstruct open: %{}, in_progress: %{}

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, %Pubsubtest.GameManager{}, default)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:add, name}, _from, games) do
    case games do
      %{^name => _} ->
        {:reply, {:error, :game_exists}, games}

      _ ->
        {:ok, pid} = GenServer.start(TicTacToeGame, %{:name => name})
        {:reply, :ok, %Pubsubtest.GameManager{games | open: Map.put_new(games.open, name, pid)}}
    end
  end

  @impl true
  def handle_call({:find, name}, _from, games) do
    open_game_pid = Map.get(games.open, name)
    in_progress_game_pid = Map.get(games.in_progress, name)
    {:reply, not_nil(open_game_pid, in_progress_game_pid), games}
  end

  @impl true
  def handle_call({:started, name}, _from, games) do
    {:reply, :ok,
     %Pubsubtest.GameManager{
       games
       | in_progress: Map.put(games.in_progress, name, Map.get(games.open, name)),
         open: Map.delete(games.open, name)
     }}
  end

  @impl true
  def handle_call({:find_open}, _from, games) do
    {:reply, :ok, games.open}
  end

  defp not_nil(nil, nil), do: nil

  defp not_nil(pid1, nil), do: pid1

  defp not_nil(nil, pid2), do: pid2
end
