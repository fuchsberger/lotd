import $ from 'jquery'

const enable = () => {

  // enable login and logout
  $('#login-button').click(() => login())
  $('#logout-button').click(() => window.userChannel.push("logout"))

  // enable switching between menu items
  window.page = 'items'

  $('a.nav-link').click(function (e) {
    e.preventDefault()
    let id = $(this).data('id')

    // do nothing if clicking on current page
    if (window.page == id) return

    // otherwise close previous page and open the new one
    $('.nav-item').removeClass('active')

    $(this).parent().addClass('active')
    $(`#${id}`).collapse('show')
    window.page = id
  })
}

export {
  enable
}
