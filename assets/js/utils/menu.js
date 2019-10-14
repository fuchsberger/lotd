import $ from 'jquery'
import { Nexus } from '../api'

const toggle_search_cancel = (on = true) => {
  if (on) {
    $('#search-control .icon-plus, #search-control .icon-search').addClass('d-none')
    $('#search-control .icon-cancel').removeClass('d-none')
  } else {
    $('#search-control .icon-plus, #search-control .icon-search').removeClass('d-none')
    $('#search-control .icon-cancel').addClass('d-none')
  }
}

const enable = () => {

  // enable login and logout
  $('#login-button').click(() => Nexus.login())
  $('#logout-button').click(() => window.userChannel.push("logout"))

  // enable switching between menu items
  window.page = 'items'

  $('a.nav-link').click(function (e) {
    e.preventDefault()
    let id = $(this).data('id')

    // do nothing if clicking on current page
    if (window.page == id) return

    // otherwise close previous page and open the new one
    window.page = id
    $('.nav-item').removeClass('active')
    $(this).parent().addClass('active')
    $(`#${id}`).collapse('show')
    search()
  })

  // enable filtering tables based on a searchfield
  $('table').on('click', 'a.search-field', function () { search($(this).text()) })

  // enable searching/filtering
  $('#search').on('keyup', function () { search(this.value) })

  // enable clearing search field and redraw currently active table
  $('#search-control a.icon-cancel').click(() => search(''))
}

const search = (term = $('#search').val()) => {
  $('#search').val(term)
  toggle_search_cancel(term != '')

  let table
  switch (window.page) {
    case 'items': table = window.item_table; break;
    case 'locations': table = window.location_table; break;
    case 'quests': table = window.quest_table; break;
    default: return;
  }
  table.search(term).draw()
  $('#search-count').text(table.page.info().recordsDisplay)
}

export {
  enable,
  search
}
