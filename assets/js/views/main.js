import $ from 'jquery'

import { login } from '../api/nexus'

export default class MainView {
  mount() {

    // Check for click events on the navbar burger icon
    $(".navbar-burger").click(() => {
      // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
      $(".navbar-burger").toggleClass("is-active")
      $(".navbar-menu").toggleClass("is-active")
    })

    // enable login button
    $('#signInBtn').click(() => login())

    // enable user button dropwdown
    enableDropdowns()
  }

  unmount() {

  }
}

const enableDropdowns = () => {
  // toggle the dropdown if the user clicks it
  $(".dropdown-trigger").click(function(){
    $(this).parent().toggleClass('is-active')
    $(this).find('.icon-angle-double-down, .icon-angle-double-up')
      .toggleClass('icon-angle-double-down icon-angle-double-up')
  })

  // Close dropdown menus on click
  $("body *").click(function (e) {
    if($(e.target).closest('.dropdown').length > 0) return
    $('.dropdown').removeClass('is-active')
    $('.dropdown').find('.icon-angle-double-up')
      .removeClass('icon-angle-double-up')
      .addClass('icon-angle-double-down')
  })
}
