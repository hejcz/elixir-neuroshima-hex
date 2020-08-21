defmodule Cartographers.State do
  alias __MODULE__

  defstruct id: nil, started: false, players: Map.new()

  def new(id) do
    %State{id: id}
  end

  def count_players(state) do
    Enum.count(state.players, fn {_id, details} -> !Map.get(details, "left", false) end)
  end

  def join(state = %State{started: false}, username) do
    is_first = count_players(state) == 0

    {:ok,
     %State{
       state
       | players: Map.put(state.players, username, %{"is_first" => is_first, "left" => false})
     }}
  end

  def join(_, _) do
    {:error, "Can't join"}
  end

  def start(state, username) do
    if Map.get(state.players, username, %{}) |> Map.get("is_first", false) do
      {:ok, %State{state | started: true}}
    else
      {:error, "Only first player can start the game"}
    end
  end

  def act(state, _username, _position) do
    {:ok, state}
  end

  def quit(state, username) do
    {:ok,
     %State{
       state
       | players: Map.update!(state.players, username, fn p -> Map.put(p, "left", true) end)
     }}
  end

  def has_left(state, username) do
    case Map.get(state.players, username) do
      nil ->
        false

      %{"left" => left} ->
        left
    end
  end

  def representation(_game) do
    %{}
  end

end
