defmodule Game do
  defstruct players: MapSet.new()

  def can_join?(_game) do
    true
  end
end

defmodule Pubsubtest.GameManager do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, %{}, default)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:add, name}, _from, games) do
    case games do
      %{^name => _} -> {:reply, {:error, :game_exists}, games}
      _ -> {:reply, :ok, Map.update(games, name, %Game{}, & &1)}
    end
  end

  @impl true
  def handle_call({:find, name}, _from, games) do
    {:reply, Map.get(games, name), games}
  end

end
