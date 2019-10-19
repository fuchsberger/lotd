import $ from 'jquery'
import socket from './socket'
import { calculate_item_counts } from './public_channel'
import { Data, Flash, Menu, Table } from '../utils'

const configure_user_channel = id => {
  let channel = socket.channel(`user:${id}`)

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.character_id != undefined) return

      const { character_id, characters } = params

      // initialize item count
      for (let i in characters) {
        if (characters.hasOwnProperty(i)) {
          characters[i].active = window.character_id == characters[i].id
          characters[i].item_count = 0
          window.items.forEach(item => {
            if(characters[i].mods.find(m => m == item.mod_id)) characters[i].item_count++
          })
        }
      }

      window.characters = characters

      Table.character(characters)

      Data.update_character(character_id)
      Data.calculate_item_counts()

      // allow collecting of items
      $('#item-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("collect_item", { id })
          .receive('ok', () => {
            let citems =
              window.character_table.cell(`#${window.character_id}`, 'items:name').data()
            citems.push(id)
            window.character_table.cell(`#${window.character_id}`, 'items:name')
              .data(citems).draw()
              update_character(window.character_id)
          })
      })

      // allow borrowing of items
      $('#item-table').on('click', 'a.check', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("remove_item", { id })
          .receive('ok', () => {
            let citems =
              window.character_table.cell(`#${window.character_id}`, 'items:name').data()
            for( var i = 0; i < citems.length; i++){
              if ( citems[i] == id) { citems.splice(i, 1); break }
            }
            window.character_table.cell(`#${window.character_id}`, 'items:name')
              .data(citems).draw()
            update_character(window.character_id)
          })
      })

      // allow activating a different character
      $('#character-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("activate_character", { id })
          .receive('ok', ({ info }) => {
            // update character table
            update_character(id)
            Flash.info(info)
          })
          .receive('error', reason => Flash.error(reason))
      })

      // allow activating mods
      $('#mod-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("activate_mod", { id })
          .receive('ok', () => {
            let cmods = window.character_table.cell(`#${window.character_id}`, 'mods:name').data()
            cmods.push(id)
            window.character_table.cell(`#${window.character_id}`, 'mods:name').data(cmods).draw()
            update_character(window.character_id)
          })
      })

      // allow deactivating mods
      $('#mod-table').on('click', 'a.check', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("deactivate_mod", { id })
          .receive('ok', () => {
            let character_mods =
              window.character_table.cell(`#${window.character_id}`, 'mods:name').data()
            for( var i = 0; i < character_mods.length; i++){
              if ( character_mods[i] == id) {
                character_mods.splice(i, 1);
                break
              }
            }
            window.character_table.cell(`#${window.character_id}`, 'mods:name')
            .data(character_mods).draw()
            update_character(window.character_id)
          })
      })

      Menu.search('')
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

export default configure_user_channel
