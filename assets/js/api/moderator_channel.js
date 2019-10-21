import $ from 'jquery'
import socket from './socket'
import { Flash, Table } from '../utils'

const add_options = name => {
  const entries = Table.get(name).data().toArray()
  for (let i in entries) {
    if (entries.hasOwnProperty(i))
      $(`#${name}_id`).append(`<option value='${entries[i].id}'>${entries[i].name}</option>`)
  }
}

const configure_moderator_channel = () => {

  if (window.moderator_channel) return

  let channel = socket.channel(`moderator`)

  channel.join()
    .receive("ok", () => {
      // add options to the add / update modal
      add_options('display')
      add_options('location')
      add_options('quest')
      add_options('mod')

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
