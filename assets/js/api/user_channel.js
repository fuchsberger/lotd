import $ from 'jquery'
import socket from './socket'
import { Menu, Table } from '../utils'

const configure_user_channel = id => {
  let channel = socket.channel(`user:${id}`)

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.character_id != undefined) return

      const { character_id, characters, mods } = params

      window.character_id = character_id
      window.characters = characters
      window.character_items = window.characters.find(c => c.id == character_id).items
      window.character_mods = window.characters.find(c => c.id == character_id).mods
      window.mods = mods

      // allow collecting of items
      $('#item-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("collect_item", { id })
          .receive('ok', () => {
            // find entry in items and mark as collected
            window.item_table.cell($(this).parent()).data(true)

            let cell = window.character_table.cell(window.character_id-1, 3)
            cell.data(cell.data() + 1).draw()

            const item = window.items.find(i => i.id == id)

            cell = window.display_table.cell(item.display_id-1, 1)
            cell.data(cell.data() + 1).draw()

            cell = window.mod_table.cell(item.mod_id-1, 3)
            cell.data(cell.data() + 1).draw()

            if (item.location_id) {
              cell = window.location_table.cell(item.location_id-1, 1)
              cell.data(cell.data() + 1).draw()
            }
            if (item.quest_id) {
              cell = window.quest_table.cell(item.quest_id-1, 1)
              cell.data(cell.data() + 1).draw()
            }
          })
      })

      // allow borrowing of items
      $('#item-table').on('click', 'a.check', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("remove_item", { id })
          .receive('ok', () => {
            // find entry in items and mark as collected
            window.item_table.cell($(this).parent()).data(false)

            let cell = window.character_table.cell(window.character_id-1, 3)
            cell.data(cell.data() - 1).draw()

            const item = window.items.find(i => i.id == id)

            cell = window.display_table.cell(item.display_id-1, 1)
            cell.data(cell.data() - 1).draw()

            cell = window.mod_table.cell(item.mod_id-1, 3)
            cell.data(cell.data() - 1).draw()

            if (item.location_id) {
              cell = window.location_table.cell(item.location_id-1, 1)
              cell.data(cell.data() - 1).draw()
            }
            if (item.quest_id) {
              cell = window.quest_table.cell(item.quest_id-1, 1)
              cell.data(cell.data() - 1).draw()
            }
          })
      })

      Table.item(window.items)
      Table.location(window.locations)
      Table.quest(window.quests)
      Table.display(window.displays)
      Table.character(characters)
      Table.mod(mods)

      // // add options to the add / update modal
      // add_options('#location_id', locations)
      // add_options('#quest_id', quests)
      // add_options('#display_id', displays)
      // add_options('#mod_id', mods)

      Menu.search('')
      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default configure_user_channel
