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

          case 'characters':
          case 'displays':
          case 'mods':
            $('#mod_id').parent().hide()
            $('#quest_id').parent().hide()
            $('#location_id').parent().hide()
            $('#display_id').parent().hide()

          case 'characters':
            $('#url').parent().hide()

          case 'locations':
          case 'quests':
            $('#quest_id').parent().hide()
            $('#location_id').parent().hide()
            $('#display_id').parent().hide()

          default:
            $('#modal h5').text(`Create ${capitalize(window.page)}`)
            $('#modal .modal-footer button').text('Create')
            $('#modal').modal('show')
        }
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
  $('#name').val('').removeClass('is-invalid')
  $('#url').val('').removeClass('is-invalid')
  $('#mod_id').val('').removeClass('is-invalid')
  $('#quest_id').val('').removeClass('is-invalid')
  $('#location_id').val('').removeClass('is-invalid')
  $('#display_id').val('').removeClass('is-invalid')
  $('.invalid-feedback').remove()

  // close modal if "add more items..." was not checked
  if (!$('#continue').is(':checked')) $('#modal').modal('hide')
}

export default configure_moderator_channel
