defmodule LotdWeb.DisplayControllerTest do
  use LotdWeb.ConnCase

  import Lotd.GalleryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all displays", %{conn: conn} do
      conn = get(conn, ~p"/displays")
      assert html_response(conn, 200) =~ "Listing Displays"
    end
  end

  describe "new display" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/displays/new")
      assert html_response(conn, 200) =~ "New Display"
    end
  end

  describe "create display" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/displays", display: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/displays/#{id}"

      conn = get(conn, ~p"/displays/#{id}")
      assert html_response(conn, 200) =~ "Show Display"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/displays", display: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Display"
    end
  end

  describe "edit display" do
    setup [:create_display]

    test "renders form for editing chosen display", %{conn: conn, display: display} do
      conn = get(conn, ~p"/displays/#{display.id}")
      assert html_response(conn, 200) =~ "Edit Display"
    end
  end

  describe "update display" do
    setup [:create_display]

    test "redirects when data is valid", %{conn: conn, display: display} do
      conn = put(conn, ~p"/displays/#{display.id}", display: @update_attrs)
      assert redirected_to(conn) == ~p"/displays/#{display.id}"

      conn = get(conn, ~p"/displays/#{display.id}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, display: display} do
      conn = put(conn, ~p"/displays/#{display.id}", display: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Display"
    end
  end

  describe "delete display" do
    setup [:create_display]

    test "deletes chosen display", %{conn: conn, display: display} do
      conn = delete(conn, ~p"/displays/#{display.id}")
      assert redirected_to(conn) == ~p"/displays"

      assert_error_sent 404, fn ->
        get(conn, ~p"/displays/#{display.id}")
      end
    end
  end

  defp create_display(_) do
    display = display_fixture()
    %{display: display}
  end
end
