defmodule Pubsubtest.GameUrl do
  def url_for_type(type, game_id) when is_binary(type) do
    url_for_type(String.to_atom(type), game_id)
  end

  def url_for_type(:tic_tac_toe, game_id) do
    PubsubtestWeb.Router.Helpers.tic_tac_toe_path(PubsubtestWeb.Endpoint, :index, game_id)
  end

  def url_for_type(:cartographers, game_id) do
    PubsubtestWeb.Router.Helpers.cartographers_path(PubsubtestWeb.Endpoint, :index, game_id)
  end
end
