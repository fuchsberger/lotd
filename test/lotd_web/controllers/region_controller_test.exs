defmodule LotdWeb.RegionControllerTest do
  use LotdWeb.ConnCase

  import Lotd.GalleryFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all regions", %{conn: conn} do
      conn = get(conn, Routes.region_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Regions"
    end
  end

  describe "new region" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.region_path(conn, :new))
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "create region" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.region_path(conn, :create), region: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.region_path(conn, :show, id)

      conn = get(conn, Routes.region_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Region"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.region_path(conn, :create), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "edit region" do
    setup [:create_region]

    test "renders form for editing chosen region", %{conn: conn, region: region} do
      conn = get(conn, Routes.region_path(conn, :edit, region))
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "update region" do
    setup [:create_region]

    test "redirects when data is valid", %{conn: conn, region: region} do
      conn = put(conn, Routes.region_path(conn, :update, region), region: @update_attrs)
      assert redirected_to(conn) == Routes.region_path(conn, :show, region)

      conn = get(conn, Routes.region_path(conn, :show, region))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, region: region} do
      conn = put(conn, Routes.region_path(conn, :update, region), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "delete region" do
    setup [:create_region]

    test "deletes chosen region", %{conn: conn, region: region} do
      conn = delete(conn, Routes.region_path(conn, :delete, region))
      assert redirected_to(conn) == Routes.region_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.region_path(conn, :show, region))
      end
    end
  end

  defp create_region(_) do
    region = region_fixture()
    %{region: region}
  end
end
