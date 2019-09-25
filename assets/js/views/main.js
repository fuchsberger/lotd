import $ from 'jquery'

import { login } from '../api/nexus'

export default class MainView {
  mount() {

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
  $(".dropdown").click(function(){
    $(this).toggleClass('is-active')
  })

  // Close dropdown menus on click
  $("body *").click(function (e) {
    if($(e.target).closest('.dropdown').length > 0) return
    $('.dropdown').removeClass('is-active')
  })
}
