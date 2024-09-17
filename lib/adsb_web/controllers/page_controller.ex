defmodule AdsbWeb.PageController do
  use AdsbWeb, :controller

  def index(conn, _params) do
    aircraft = Adsb.Aircraft.Handler.get_aircraft()
    render(conn, :index, layout: false, aircraft: aircraft)
  end
end
