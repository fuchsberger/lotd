defmodule LotdWeb.Icons do

  use Phoenix.HTML

  defp path(d), do: tag :path, fill: "currentColor", d: d

  defp svg(paths, opts), do: content_tag :svg, paths, opts

  def icon(:checkmark, class) do
    svg(path("M400 480H48c-27 0-48-21-48-48V80c0-27 21-48 48-48h352c27 0 48 21 48 48v352c0 27-21 48-48 48zm-205-98l184-184c7-6 7-16 0-23l-22-22c-7-7-17-7-23 0L184 303l-70-70c-6-7-16-7-23 0l-22 22c-7 7-7 17 0 23l104 104c6 6 16 6 22 0z"), class: class, viewBox: "0 0 448 512")
  end
end
