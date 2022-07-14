defmodule LotdWeb.Api.DisplayController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Display
  alias LotdWeb.Api.DisplayView

  def index(conn, _params) do
    render(conn, "displays.json", displays: Gallery.list_displays())
  end

  def create(conn, %{"display" => display_params}) do
    case Gallery.create_display(display_params) do
      {:ok, display} ->
        display = Gallery.preload_display(display)
        json(conn, %{
          success: true,
          display: DisplayView.render("display.json", display: display )
        })

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "display" => display_params}) do
    with %Display{} = display <- Gallery.get_display!(id) do
      case Gallery.update_display(display, display_params) do
        {:ok, display} ->
          display = Gallery.preload_display(display)
          json(conn, %{success: true, display: DisplayView.render("display.json", display: display)})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Display{} = display <- Gallery.get_display!(id),
        {:ok, display} = Gallery.delete_display(display) do
      json(conn, %{success: true, deleted_id: display.id})
    end
  end
end
