defmodule AntiquarWeb.PageController do
  use AntiquarWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
