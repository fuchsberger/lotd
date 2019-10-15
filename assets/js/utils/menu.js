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

  $('a.tab').click(function (e) {
    e.preventDefault()
    let id = $(this).data('id')

    // do nothing if clicking on current page
    if (window.page == id) return

    // otherwise close previous page and open the new one
    window.page = id
    $('.nav-item').removeClass('active')
    $(this).parent().addClass('active')
    $(`#${id}`).collapse('show')
    if(id != 'about') search()
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
    case 'characters': table = window.character_table; break;
    case 'displays': table = window.display_table; break;
    case 'items': table = window.item_table; break;
    case 'locations': table = window.location_table; break;
    case 'mods': table = window.mod_table; break;
    case 'quests': table = window.quest_table; break;
    case 'users': table = window.user_table; break;
    default: return;
  }

  // filter table and remove rows that do not have a matching row id
  if (!window.character_id || window.page == 'characters' || window.page == 'displays') {
    table.search(term).draw()
  } else {
    const modIDs = window.mod_table.rows().data().toArray()
      .filter(m => m.active).map(m => m.id).toString().replace(/,/g, "|")
    table.search(term).columns('mod:name').search(modIDs, true).draw()
  }
  $('#search-count').text(table.page.info().recordsDisplay)
}

export {
  enable,
  search
}
