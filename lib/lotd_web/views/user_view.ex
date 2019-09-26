defmodule LotdWeb.UserView do
  use LotdWeb, :view

  alias Lotd.Accounts.User

  def user_roles(%User{} = u) do
    cond do
      u.admin && u.moderator ->
        "Admin, Moderator"
      u.admin ->
        "Admin"
      u.moderator ->
        "Moderator"
      true ->
        ""
    end
  end

  def user_actions(conn, %User{} = u) do
    cond do
      u.admin && u.moderator ->
        [btn_remove_admin(conn, u), btn_remove_moderator(conn, u)]
      u.admin ->
        [btn_remove_admin(conn, u), btn_add_moderator(conn, u)]
      u.moderator ->
        [btn_add_admin(conn, u), btn_remove_moderator(conn, u)]
      true ->
        [btn_add_admin(conn, u), btn_add_moderator(conn, u)]
    end
  end

  def btn_add_admin(conn, user) do
    link icon("user-plus", class: "has-text-link"),
      to: Routes.page_path(conn, :index),
      method: "put"
  end

  def btn_remove_admin(conn, user) do
    link icon("user-remove", class: "has-text-link"),
      to: Routes.page_path(conn, :index),
      method: "put"
  end

  def btn_add_moderator(conn, user) do
    link icon("user-plus", class: "has-text-dark"),
      to: Routes.page_path(conn, :index),
      method: "put"
  end

  def btn_remove_moderator(conn, user) do
    link icon("user-remove", class: "has-text-dark"),
      to: Routes.page_path(conn, :index),
      method: "put"
  end
end
