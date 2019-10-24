import $ from 'jquery'
import socket from './socket'
import { Data, Flash, Menu, Table } from '../utils'

const configure_user_channel = id => {

  if (window.user_channel) return

  let channel = socket.channel(`user:${id}`)

  // listen for events
  channel.on('add-character', character => Data.add_character(character))
  channel.on('update-character', ({ id, name }) => Data.rename_character(id, name))
  channel.on('delete-character', ({ id }) => Data.delete_character(id))

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.userChannel) return

      const { character_id, characters } = params

      // create character table and activate current caracter
      Table.character(characters)
      Data.activate_character(character_id)

      // allow collecting of items
      $('#item-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("collect_item", { id }).receive('ok', () => Data.collect_item(id))
      })

      // allow borrowing of items
      $('#item-table').on('click', 'a.check', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("remove_item", { id }).receive('ok', () => Data.remove_item(id))
      })

      // allow activating a different character
      $('#character-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("activate_character", { id })
          .receive('ok', () => Data.activate_character(id))
          .receive('error', reason => Flash.error(reason))
      })

      // allow activating mods
      $('#mod-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("activate_mod", { id }).receive('ok', () => Data.activate_mod(id))
      })

      // allow deactivating mods
      $('#mod-table').on('click', 'a.check', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("deactivate_mod", { id }).receive('ok', () => Data.deactivate_mod(id))
      })

      window.character_table.column('edit:name').visible(true).draw()
      Menu.search('')

      window.userChannel = channel
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

export default configure_user_channel
