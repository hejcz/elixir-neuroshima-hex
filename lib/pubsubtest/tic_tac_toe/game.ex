defmodule TicTacToe.Game do
  @moduledoc """
  pid = Pubsubtest.GameManager.add_game(Pubsubtest.GameManager, "test2")
  TicTacToe.Game.join(pid, "julek")
  TicTacToe.Game.join(pid, "tomek")
  TicTacToe.Game.start(pid, "julek")
  TicTacToe.Game.draw(pid, "julek", 1)
  TicTacToe.Game.draw(pid, "tomek", 2)
  TicTacToe.Game.draw(pid, "julek", 5)
  TicTacToe.Game.draw(pid, "tomek", 4)
  TicTacToe.Game.draw(pid, "julek", 9)
  """

  use GenServer
  alias TicTacToe.State

  @impl true
  @spec init(%{id: any}) :: {:ok, TicTacToe.State.t()}
  def init(%{:id => id}) do
    {:ok, State.new(id)}
  end

  def join(game, username) do
    GenServer.call(game, {:join, username})
  end

  def start(game, username) do
    GenServer.call(game, {:start, username})
  end

  def draw(game, username, position) do
    GenServer.call(game, {:draw, username, position})
  end

  def quit(game, username) do
    GenServer.call(game, {:quit, username})
  end

  def representation(game) do
    GenServer.call(game, :representation)
  end

  def has_left(game, username) do
    GenServer.call(game, {:has_left, username})
  end

  @impl true
  def handle_call({:join, username}, _from, state) do
    case result = State.join(state, username) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      {:error, _} -> {:reply, result, state}
    end
  end

  @impl true
  def handle_call({:start, username}, _from, state) do
    case result = State.start(state, username) do
      {:ok, new_state} ->
        Pubsubtest.GameManager.start_game(Pubsubtest.GameManager, new_state.id)
        {:reply, :ok, new_state}

      {:error, _} ->
        {:reply, result, state}
    end
  end

  @impl true
  def handle_call({:draw, username, position}, _from, state) do
    case result = State.draw(state, username, position) do
      {:ok, new_state} -> {:reply, State.representation(new_state), new_state}
      {:error, _} -> {:reply, result, state}
    end
  end

  @impl true
  def handle_call({:quit, username}, _from, state) do
    case result = State.quit(state, username) do
      {:ok, new_state} ->
        if State.count_players(new_state) == 0 do
          IO.inspect("removed")
          Pubsubtest.GameManager.remove(Pubsubtest.GameManager, new_state.id)
        end

        {:reply, :ok, new_state}

      {:error, _} ->
        {:reply, result, state}
    end
  end

  @impl true
  def handle_call({:has_left, username}, _from, state) do
    {:reply, State.has_left(state, username), state}
  end

  @impl true
  def handle_call(:representation, _from, state) do
    {:reply, State.representation(state), state}
  end
end
