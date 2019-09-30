defmodule LotdWeb.ItemControllerTest do
  use LotdWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 302) =~ "<html><body>You are being <a href=\"/items\">redirected</a>.</body></html>"
  end
end
