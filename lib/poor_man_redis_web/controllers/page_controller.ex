defmodule PoorManRedisWeb.PageController do
  use PoorManRedisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
