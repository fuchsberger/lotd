import $ from 'jquery'
import timeago from 'timeago'

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

    // enable timeago
    $("time").timeago()
  }

  unmount() {

  }
}
