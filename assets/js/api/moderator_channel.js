import $ from 'jquery'
import socket from './socket'
import { Flash, Menu, Table } from '../utils'

const add_option = (selector, entry) =>
  $(selector).append(`<option value='${entry.id}'>${entry.name}</option>`)

const add_options = name => {
  const entries = Table.get(name).data().toArray()
  for (let i in entries) {
    if(entries.hasOwnProperty(i)) add_option(`#${name}_id`, entries[i])
  }
}

const capitalize = s => s.charAt(0).toUpperCase() + s.slice(1,-1)

const configure_moderator_channel = () => {
  let channel = socket.channel(`moderator`)

  channel.join()
    .receive("ok", () => {

      // add options to the add / update modal
      add_options('display')
      add_options('location')
      add_options('quest')
      add_options('mod')

      // enable add button
      $('#search-control a.icon-plus').click(() => {
        reset_modal()

        switch (window.page) {
          case 'about':
          case 'users':
            return

          case 'items':
              $('#quest_id').parent().show()
              $('#location_id').parent().show()
              $('#display_id').parent().show()

          case 'locations':
          case 'quests':
            $('#mod_id').parent().show()

          case 'characters':
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
        const data = Table.get(window.page.slice(0, -1)).row(`#${id}`).data()

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

          case 'locations':
          case 'quests':
              $('#mod_id').parent().show()

          case 'characters':
            $('#url').parent().hide()

          default:
            $('#modal h5').text(`Edit ${capitalize(window.page)}`)
            $('#submit').text('Update')
            $('#modal').modal('show')
        }
      })

    // allow deleting of items
    if (window.admin) {
      $('#delete').on('click', function () {
        channel.push(`delete-${window.page.slice(0,-1)}`, { id: $(this).data('id') })
      })
    }

    // allow adding / modifying entries
    $('#modal form').submit(function (e) {
      e.preventDefault()

      const data = $(this).serializeArray().reduce(function(obj, item) {
        obj[item.name] = item.value;
        return obj;
      }, {})

      const event = $('#submit').text().toLowerCase() + '-' +  window.page.slice(0,-1)

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

      // show moderator columns
      window.item_table.column('edit:name').visible(true).draw()
      window.display_table.column('edit:name').visible(true).draw()
      window.location_table.column('edit:name').visible(true).draw()
      window.mod_table.column('edit:name').visible(true).draw()
      window.quest_table.column('edit:name').visible(true).draw()
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

const reset_modal = () => {
  // reset form
  $('#name').val('').removeClass('is-invalid').parent().show()
  $('#url').val('').removeClass('is-invalid').parent().show()
  $('#mod_id').val('').removeClass('is-invalid').parent().hide()
  $('#quest_id').val('').removeClass('is-invalid').parent().hide()
  $('#location_id').val('').removeClass('is-invalid').parent().hide()
  $('#display_id').val('').removeClass('is-invalid').parent().hide()
  $('.invalid-feedback').remove()
  $('#delete').hide()
}

export default configure_moderator_channel
