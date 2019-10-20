import $ from 'jquery'
import { Nexus } from '../api'
import * as Table from './table'

const capitalize = s => s.charAt(0).toUpperCase() + s.slice(1)

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

  // enable add button
  $('#search-control').on('click', 'a.icon-plus', () => {
    reset_modal()

    switch (window.page) {
      case 'about':
      case 'user':
        return

      case 'item':
          $('#quest_id').parent().show()
          $('#location_id').parent().show()
          $('#display_id').parent().show()

      case 'location':
      case 'quest':
        $('#mod_id').parent().show()

      case 'character':
        $('#url').parent().hide()

      default:
        $('#modal h5').text(`Create ${capitalize(window.page)}`)
        $('#submit').text('Add')
        $('#modal').modal('show')
    }
  })

  // enable edit button
  $('table').on('click', 'td a.icon-pencil', function () {

    reset_modal()
    const id = parseInt($(this).closest('tr').attr('id'))
    const data = Table.get(window.page).row(`#${id}`).data()

    $('#name').val(data.name || '')
    $('#url').val(data.url || '')
    $('#display_id').val(data.display_id || '')
    $('#mod_id').val(data.mod_id || '')
    $('#location_id').val(data.location_id || '')
    $('#quest_id').val(data.quest_id || '')

    switch (window.page) {
      case 'about':
      case 'users':
        return

      case 'items':
        $('#quest_id').parent().show()
        $('#location_id').parent().show()
        $('#display_id').parent().show()

      case 'location':
      case 'quest':
          $('#mod_id').parent().show()

      case 'character':
        $('#url').parent().hide()

      default:
        $('#modal h5').text(`Edit ${capitalize(window.page)}`)
        $('#submit').text('Update')
        $('#modal').modal('show')
    }
  })


  // allow adding / modifying entries
  $('#modal form').submit(function (e) {
    e.preventDefault()

    const data = $(this).serializeArray().reduce(function(obj, item) {
      obj[item.name] = item.value;
      return obj;
    }, {})

    const event = $('#submit').text().toLowerCase() + '-' + window.page

    const channel = window.page == 'character' ? window.userChannel : window.moderatorChannel

    channel.push(event, data)
      .receive('ok', () => {
        // close modal if "add more entries..." was not checked
        if (!$('#continue').is(':checked')) $('#modal').modal('hide')
      })
      .receive('error', ({ errors }) => {
        for (var key in errors) {
          if (errors.hasOwnProperty(key)) {
            $(`#${key}`).addClass('is-invalid')
              .after(`<div class="invalid-feedback">${errors[key]}</div>`)
          }
        }
      })
  })
}

const reset_modal = () => {
  $('#name, #url').val('').removeClass('is-invalid').parent().show()
  $('#mod_id, #quest_id, #location_id, #display_id').val('').removeClass('is-invalid').parent().hide()
  $('.invalid-feedback').remove()
  $('#delete').hide()
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
