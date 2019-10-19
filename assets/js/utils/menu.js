import $ from 'jquery'
import { Nexus } from '../api'
import * as Table from './table'

const search_control = () => {
  let content
  if ($('#search').val() != '')
    content = "<a class='icon-cancel text-primary'></a>"
  else if (window.moderator || window.admin || (window.user &&
    (window.page == 'characters' || window.page == 'mods')))
    content = "<a class='icon-plus'></a>"
  else
    content = "<i class='icon-search text-black-50'></i>"

  $('#search-control .input-group-prepend .input-group-text').html(content)
}

const switch_tab = e => {

  const tab = $(e.target).data('id')

  // do nothing if we are already at correct page
  if (window.page == tab) return

  window.page = tab

  // mark the correct tab as active
  $('.nav-item').removeClass('active')
  $(e.target).parent().addClass('active')

  // disable search on about page
  if (tab == 'about')
    $('#search').attr('disabled', true).siblings('.input-group-append').addClass('d-none')
  else {
    $('#search').attr('disabled', false).siblings('.input-group-append').removeClass('d-none')

    // provide the right search control option
    search_control()

    // update search in target table
    search()
  }

  // enable and show new page
  $(`#${tab}`).collapse('show')
}

const enable = () => {

  // enable switching between menu items
  window.page = 'item'

  // enable login and logout
  $('#login-button').click(() => Nexus.login())
  $('#logout-button').click(() => window.userChannel.push("logout"))

  // provide the right search control option
  search_control()

  // allow to navigate different tabs
  $('a.tab').click(switch_tab)

  // enable filtering tables based on a searchfield
  $('table').on('click', 'a.search-field', function () { search($(this).text()) })

  // enable searching/filtering
  $('#search').on('keyup', function () { search(this.value) })

  // enable clearing search field and redraw currently active table
  $('#search-control').on('click', 'a.icon-cancel', () => search(''))
}

const search = (term = $('#search').val()) => {
  $('#search').val(term)
  search_control()
  Table.get(window.page).search(term).draw()
  $('#search-count').text(Table.get(window.page).page.info().recordsDisplay)
}

export {
  enable,
  search
}
