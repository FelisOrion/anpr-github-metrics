defmodule GitmetricsWeb.PageController do
  use GitmetricsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
