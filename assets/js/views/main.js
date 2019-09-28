import $ from 'jquery'

import { login } from '../api/nexus'

export default class MainView {
  mount() {

    // Check for click events on the navbar burger icon
    $(".navbar-burger").click(() => {
      // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
      $(".navbar-burger, .navbar-menu").toggleClass("is-active")
    })

    // enable login button
    $('#signInBtn').click(() => login())

    // enable dismissing of notifications
    $('.notification button.delete').on('click', function(){ $(this).parent().remove() })
  }

  unmount() {
    // save current scroll position and view so after reloading same view it should scroll down
    sessionStorage.lastView = $('body').data('view')
    sessionStorage.scrollTop = $(window).scrollTop()
  }
}
