import $ from "jquery"

// enable mobile menu and user-dropdown
$(document).on("click", () => {
  $("#mobile-menu").addClass("hidden")
  $("#user-dropdown-menu").addClass("hidden")
  $("#more-dropdown-menu").addClass("hidden")
})

$("#mobile-menu-button").on("click", e => {
  e.stopPropagation()
  $("#mobile-menu").toggleClass("hidden")
})

$("#mobile-menu").on("click", e => { e.stopPropagation()})

$("#user-dropdown-button").on("click", e => {
  e.stopPropagation()
  $("#user-dropdown-menu").toggleClass("hidden")
  $("#more-dropdown-menu").addClass("hidden")
})

$("#more-dropdown-button").on("click", e => {
  e.stopPropagation()
  $("#more-dropdown-menu").toggleClass("hidden")
  $("#user-dropdown-menu").addClass("hidden")
})

// enable dismissing of alerts
$(".alert button").on("click", el => {
  $(el.currentTarget).closest(".alert").remove()
})
