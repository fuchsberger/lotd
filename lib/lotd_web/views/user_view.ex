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

  defp btn_add_admin(conn, user) do
    link icon("user-plus", class: "has-text-link"),
      to: Routes.user_path(conn, :update, user, admin: true),
      method: "put",
      title: "Add Admin"
  end

  defp btn_remove_admin(conn, user) do
    link icon("user-times", class: "has-text-link"),
      to: Routes.user_path(conn, :update, user, admin: false),
      method: "put",
      title: "Remove Admin"
  end

  defp btn_add_moderator(conn, user) do
    link icon("user-plus", class: "has-text-dark"),
      to: Routes.user_path(conn, :update, user, moderator: true),
      method: "put",
      title: "Add Moderator"
  end

  defp btn_remove_moderator(conn, user) do
    link icon("user-times", class: "has-text-dark"),
      to: Routes.user_path(conn, :update, user, moderator: false),
      method: "put",
      title: "Remove Moderator"
  end
end
