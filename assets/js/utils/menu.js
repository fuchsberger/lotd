import $ from 'jquery'
import { Nexus } from '../api'

const enable = () => {

  // enable login and logout
  $('#login-button').click(() => Nexus.login())
  $('#logout-button').click(() => window.userChannel.push("logout"))

  // enable filtering tables based on a searchfield
  // $('table').on('click', 'a.search-field', function () { search($(this).text()) })

  // enable clearing search field and redraw currently active table
  // $('#search-control').on('click', 'a.icon-cancel', () => search(''))
}

const search = (term = $('#search').val()) => {
  $('#search').val(term)
  window.table.search(term).draw()
  $('#search-count').text(window.table.page.info().recordsDisplay)
}

export {
  enable,
  search
}
