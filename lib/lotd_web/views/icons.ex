defmodule LotdWeb.Icons do

  use Phoenix.HTML

  # Some icons are creative property of Font Awesome
  # Licenced under Attribution 4.0 International (CC by 4.0)
  # https://fontawesome.com/license/free

  @check_square "M400 480H48c-27 0-48-21-48-48V80c0-27 21-48 48-48h352c27 0 48 21 48 48v352c0 27-21 48-48 48zm-205-98l184-184c7-6 7-16 0-23l-22-22c-7-7-17-7-23 0L184 303l-70-70c-6-7-16-7-23 0l-22 22c-7 7-7 17 0 23l104 104c6 6 16 6 22 0z"

  @plus_square "M352 240v32c0 7-5 12-12 12h-88v88c0 7-5 12-12 12h-32c-7 0-12-5-12-12v-88h-88c-7 0-12-5-12-12v-32c0-7 5-12 12-12h88v-88c0-7 5-12 12-12h32c7 0 12 5 12 12v88h88c7 0 12 5 12 12zm96-160v352c0 27-21 48-48 48H48c-26 0-48-21-48-48V80c0-26 22-48 48-48h352c27 0 48 22 48 48zm-48 346V86c0-3-3-6-6-6H54c-3 0-6 3-6 6v340c0 3 3 6 6 6h340c3 0 6-3 6-6z"

  defp path(d, opts \\ []), do:  tag :path, Keyword.merge([fill: "currentColor", d: d], opts)

  defp svg(paths, opts), do: content_tag :svg, paths, opts

  def icon(:toggle, active?) do
    svg (if active?, do: path(@check_square), else: path(@plus_square)),
      class: "inline-block w-6 h-5 #{if active?, do: "text-green-500", else: "text-gray-500"}",
      viewBox: "0 0 448 512"
  end
end
