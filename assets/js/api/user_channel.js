import $ from 'jquery'
import socket from './socket'
import { calculate_item_counts } from './public_channel'
import { Flash, Menu, Table } from '../utils'

const update_character = id => {

  // update character table
  if (window.character_id)
    window.character_table.cell(`#${window.character_id}`, 0).data(false).draw()
  window.character_table.cell(`#${id}`, 0).data(true).draw()

  const character_items = window.character_table.cell(`#${id}`, 'items:name').data()

  // update items / locations / display tables
  const items = window.item_table.rows().data().toArray()

  const display_count = {}, location_count = {}, mod_count = {}, quest_count = {}

  for (let i = 0; i < items.length; i++) {
    const item = items[i]
    const active = character_items.find(citem => citem == item.id) != undefined
    window.item_table.cell(`#${item.id}`, 'active:name').data(active).draw()

    // count displays
    if (active) {

      // count displays
      if (display_count[item.display_id]) display_count[item.display_id]++
      else display_count[item.display_id] = 1

      // count mods
      if (mod_count[item.mod_id]) mod_count[item.mod_id]++
      else mod_count[item.mod_id] = 1

      // count locations
      if (item.location_id) {
        if (location_count[item.location_id]) location_count[item.location_id]++
        else location_count[item.location_id] = 1
      }

      // count quests
      if (item.quest_id) {
        if (quest_count[item.quest_id]) quest_count[item.quest_id]++
        else quest_count[item.quest_id] = 1
      }
    }
  }

  // update display table
  const displays = window.display_table.rows().ids().toArray()
  for (let i = 0; i < displays.length; i++) {
    const count = display_count[displays[i]] || 0
    window.display_table.cell(`#${displays[i]}`, 'found:name').data(count).draw()
  }

  // update location table
  const locations = window.location_table.rows().ids().toArray()
  for (let i = 0; i < locations.length; i++) {
    const count = location_count[locations[i]] || 0
    window.location_table.cell(`#${locations[i]}`, 'found:name').data(count).draw()
  }

  // update quest table
  const quests = window.quest_table.rows().ids().toArray()
  for (let i = 0; i < quests.length; i++) {
    const count = quest_count[quests[i]] || 0
    window.quest_table.cell(`#${quests[i]}`, 'found:name').data(count).draw()
  }

  // update mod table
  const character_mods = window.character_table.cell(`#${id}`, 'mods:name').data()
  const mods = window.mod_table.rows().ids().toArray()
  for (let i = 0; i < mods.length; i++) {
    const active = character_mods.find(m => m == mods[i]) != undefined
    const count = mod_count[mods[i]] || 0
    window.mod_table.cell(`#${mods[i]}`, 'active:name').data(active).draw()
    window.mod_table.cell(`#${mods[i]}`, 'found:name').data(count).draw()
  }

  // show all user columns
  window.item_table.column('active:name').visible(true).draw()
  window.display_table.column('found:name').visible(true).draw()
  window.location_table.column('found:name').visible(true).draw()
  window.mod_table.columns(['active:name', 'found:name']).visible(true).draw()
  window.quest_table.column('found:name').visible(true).draw()

  window.character_id = id
}

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

      update_character(character_id)
      calculate_item_counts()

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
