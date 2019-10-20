defmodule LotdWeb.DataView do
  use LotdWeb, :view

  def render("character.json", %{ data: c }) do
    %{
      id: c.id,
      items: c.items,
      mods: c.mods,
      name: c.name,
      created: NaiveDateTime.to_iso8601(c.inserted_at) <> "Z"
    }
  end

  def render("display.json", %{ data: d }) do
    %{
      id: d.id,
      name: d.name,
      url: d.url
    }
  end

  def render("item.json", %{ data: i }) do
    %{
      active: false,
      id: i.id,
      name: i.name,
      url: i.url,
      location_id: i.location_id,
      quest_id: i.quest_id,
      mod_id: i.mod_id,
      display_id: i.display_id
    }
  end

  def render("location.json", %{ data: l }) do
    %{
      id: l.id,
      name: l.name,
      url: l.url,
      mod_id: l.mod_id
    }
  end

  def render("mod.json", %{ data: m }) do
    %{
      active: false,
      id: m.id,
      filename: m.filename,
      name: m.name,
      url: m.url
    }
  end

  def render("quest.json", %{ data: q }) do
    %{
      id: q.id,
      name: q.name,
      url: q.url,
      mod_id: q.mod_id
    }
  end

  def render("user.json", %{ data: u }) do
    %{
      id: u.id,
      admin: u.admin,
      moderator: u.moderator,
      nexus_name: u.nexus_name,
      nexus_id: u.nexus_id,
      created: NaiveDateTime.to_iso8601(u.inserted_at) <> "Z"
    }
  end
end
