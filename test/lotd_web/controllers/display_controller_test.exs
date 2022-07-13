defmodule LotdWeb.DisplayControllerTest do
  use LotdWeb.ConnCase

  import Lotd.GalleryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all displays", %{conn: conn} do
      conn = get(conn, Routes.display_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Displays"
    end
  end

  describe "new display" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.display_path(conn, :new))
      assert html_response(conn, 200) =~ "New Display"
    end
  end

  describe "create display" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.display_path(conn, :create), display: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.display_path(conn, :show, id)

      conn = get(conn, Routes.display_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Display"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.display_path(conn, :create), display: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Display"
    end
  end

  describe "edit display" do
    setup [:create_display]

    test "renders form for editing chosen display", %{conn: conn, display: display} do
      conn = get(conn, Routes.display_path(conn, :edit, display))
      assert html_response(conn, 200) =~ "Edit Display"
    end
  end

  describe "update display" do
    setup [:create_display]

    test "redirects when data is valid", %{conn: conn, display: display} do
      conn = put(conn, Routes.display_path(conn, :update, display), display: @update_attrs)
      assert redirected_to(conn) == Routes.display_path(conn, :show, display)

      conn = get(conn, Routes.display_path(conn, :show, display))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, display: display} do
      conn = put(conn, Routes.display_path(conn, :update, display), display: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Display"
    end
  end

  describe "delete display" do
    setup [:create_display]

    test "deletes chosen display", %{conn: conn, display: display} do
      conn = delete(conn, Routes.display_path(conn, :delete, display))
      assert redirected_to(conn) == Routes.display_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.display_path(conn, :show, display))
      end
    end
  end

  defp create_display(_) do
    display = display_fixture()
    %{display: display}
  end
end
