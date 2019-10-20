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

const configure_moderator_channel = () => {
  let channel = socket.channel(`moderator`)

  channel.join()
    .receive("ok", () => {

      // add options to the add / update modal
      add_options('display')
      add_options('location')
      add_options('quest')
      add_options('mod')

      // allow deleting of items
      if (window.admin) {
        $('#delete').on('click', function () {
          channel.push(`delete-${window.page.slice(0,-1)}`, { id: $(this).data('id') })
        })
      }

      // show moderator columns
      window.item_table.column('edit:name').visible(true).draw()
      window.display_table.column('edit:name').visible(true).draw()
      window.location_table.column('edit:name').visible(true).draw()
      window.mod_table.column('edit:name').visible(true).draw()
      window.quest_table.column('edit:name').visible(true).draw()

      window.moderatorChannel = channel
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}


export default configure_moderator_channel
