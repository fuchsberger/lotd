import $ from 'jquery'

import { login } from '../api/nexus'



export default class MainView {
  mount() {

    // enable login button
    $('#signInBtn').click(() => login())

    // enable user button dropwdown
    enableDropdowns()


    // $(document).click(() => $('#user-button').parent().removeClass('is-active'))
    // $('#user-button').click(() => $('#user-button').parent().toggleClass('is-active'))
  }

  unmount() {
    // This will be executed when the document unloads...

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
