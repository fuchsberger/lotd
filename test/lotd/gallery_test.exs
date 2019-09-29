defmodule Lotd.GalleryTest do
  use Lotd.DataCase

  alias Lotd.Gallery

  describe "items" do
    alias Lotd.Gallery.Item

    @valid_attrs %{name: "some name", url: "some url"}
    @update_attrs %{name: "some updated name", url: "some updated url"}
    @invalid_attrs %{name: nil, url: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Gallery.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Gallery.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Gallery.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Gallery.create_item(@valid_attrs)
      assert item.name == "some name"
      assert item.url == "some url"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Gallery.update_item(item, @update_attrs)
      assert item.name == "some updated name"
      assert item.url == "some updated url"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_item(item, @invalid_attrs)
      assert item == Gallery.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Gallery.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Gallery.change_item(item)
    end
  end

  describe "displays" do
    alias Lotd.Gallery.Display

    @valid_attrs %{name: "some name", url: "some url"}
    @update_attrs %{name: "some updated name", url: "some updated url"}
    @invalid_attrs %{name: nil, url: nil}

    def display_fixture(attrs \\ %{}) do
      {:ok, display} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Gallery.create_display()

      display
    end

    test "list_displays/0 returns all displays" do
      display = display_fixture()
      assert Gallery.list_displays() == [display]
    end

    test "get_display!/1 returns the display with given id" do
      display = display_fixture()
      assert Gallery.get_display!(display.id) == display
    end

    test "create_display/1 with valid data creates a display" do
      assert {:ok, %Display{} = display} = Gallery.create_display(@valid_attrs)
      assert display.name == "some name"
      assert display.url == "some url"
    end

    test "create_display/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_display(@invalid_attrs)
    end

    test "update_display/2 with valid data updates the display" do
      display = display_fixture()
      assert {:ok, %Display{} = display} = Gallery.update_display(display, @update_attrs)
      assert display.name == "some updated name"
      assert display.url == "some updated url"
    end

    test "update_display/2 with invalid data returns error changeset" do
      display = display_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_display(display, @invalid_attrs)
      assert display == Gallery.get_display!(display.id)
    end

    test "delete_display/1 deletes the display" do
      display = display_fixture()
      assert {:ok, %Display{}} = Gallery.delete_display(display)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_display!(display.id) end
    end

    test "change_display/1 returns a display changeset" do
      display = display_fixture()
      assert %Ecto.Changeset{} = Gallery.change_display(display)
    end
  end
end
