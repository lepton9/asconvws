defmodule AsconvwsWeb.PageController do
  use AsconvwsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
