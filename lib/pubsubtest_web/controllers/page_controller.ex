defmodule PubsubtestWeb.PageController do
  use PubsubtestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
