# defmodule LotdWeb.Components.Toggle do
#   use Phoenix.Component

#   @doc """
#     Toggle Element
#     based on [Tailwind UI](https://tailwindui.com/components/application-ui/forms/toggles)

#     __Usage:__
#     ```heex
#     <.toggle icon|short enabled={true|false}/>
#     ```
#   """
#   def toggle(assigns \\ %{}) do
#     assigns = assigns
#       |> assign_new(:class, fn -> "" end)
#       |> assign_new(:enabled, fn -> false end)
#       |> assign_new(:short, fn -> nil end)
#       |> assign_new(:icon, fn -> nil end)
#       |> assign_new(:extra_attributes, fn ->
#         Map.drop(assigns, [
#           :area_checked,
#           :class,
#           :enabled,
#           :icon,
#           :short,
#           :__slot__,
#           :__changed__
#         ])
#       end)

#     ~H"""
#     <button type="button" class={button_classes(@enabled, @short, @class)} role="switch" aria-checked={@enabled} {@extra_attributes}>
#       <span class="sr-only">umschalten</span>
#       <%= cond do %>
#         <% @icon -> %>
#           <span class={"#{translate_class(@enabled)} pointer-events-none relative inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"}>
#             <span class={"#{if @enabled, do: "opacity-0 ease-out duration-100", else: "opacity-100 ease-in duration-200"} absolute inset-0 h-full w-full flex items-center justify-center transition-opacity"} aria-hidden="true">
#               <svg class="h-3 w-3 text-gray-400" fill="none" viewBox="0 0 12 12">
#                 <path d="M4 8l2-2m0 0l2-2M6 6L4 4m2 2l2 2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
#               </svg>
#             </span>
#             <span class={"#{if @enabled, do: "opacity-100 ease-in duration-200", else: "opacity-0 ease-out duration-100"} absolute inset-0 h-full w-full flex items-center justify-center transition-opacity"} aria-hidden="true">
#               <svg class="h-3 w-3 text-indigo-600" fill="currentColor" viewBox="0 0 12 12">
#                 <path d="M3.707 5.293a1 1 0 00-1.414 1.414l1.414-1.414zM5 8l-.707.707a1 1 0 001.414 0L5 8zm4.707-3.293a1 1 0 00-1.414-1.414l1.414 1.414zm-7.414 2l2 2 1.414-1.414-2-2-1.414 1.414zm3.414 2l4-4-1.414-1.414-4 4 1.414 1.414z" />
#               </svg>
#             </span>
#           </span>

#         <% @short -> %>
#           <span aria-hidden="true" class="pointer-events-none absolute bg-white w-full h-full rounded-md"></span>
#           <span aria-hidden="true" class={"#{bg_class(@enabled)} pointer-events-none absolute h-4 w-9 mx-auto rounded-full transition-colors ease-in-out duration-200"}></span>
#           <span aria-hidden="true" class={"#{translate_class(@enabled)} pointer-events-none absolute left-0 inline-block h-5 w-5 border border-gray-200 rounded-full bg-white shadow transform ring-0 transition-transform ease-in-out duration-200"}></span>

#         <% true -> %>
#           <span aria-hidden="true" class={"#{translate_class(@enabled)} pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"}></span>
#       <% end %>
#     </button>
#     """
#   end

#   defp button_classes(enabled, short, class) do
#     Enum.join([specific_classes(enabled, short), base_classes(), class], " ")
#   end

#   defp specific_classes(e, nil), do: "#{bg_class(e)} h-6 w-11 border-2 border-transparent transition-colors ease-in-out duration-200"
#   defp specific_classes(_enabled, _short), do: "group items-center justify-center h-5 w-10"

#   defp base_classes do
#     "relative inline-flex flex-shrink-0 rounded-full cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
#   end

#   defp bg_class(enabled) do
#     if enabled, do: "bg-indigo-600", else: "bg-gray-200"
#   end

#   defp translate_class(enabled) do
#     if enabled, do: "translate-x-5", else: "translate-x-0"
#   end
# end
