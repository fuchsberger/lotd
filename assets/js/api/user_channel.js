import $ from 'jquery'
import socket from './socket'
import { Flash, Menu, Table } from '../utils'

const add_options = (selector, entries) => {
  for (let i in entries) {
    if(entries.hasOwnProperty(i))
      $(selector).append(`<option value='${entries[i].id}'>${entries[i].name}</option>`)
  }
}

const switch_character = id => {

  // window.character_items = window.characters.find(c => c.id == id).items

  // update character table
  if (window.character_id)
    window.character_table.cell(`#${window.character_id}`, 0).data(false).draw()
  window.character_table.cell(`#${id}`, 0).data(true).draw()

  // update mods table

  const character_items = window.character_table.cell(`#${id}`, 'items:name').data()
  // const character_mods = window.character_table.cell(`#${id}`, 'mods:name').data()

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
  const mods = window.mod_table.rows().ids().toArray()
  for (let i = 0; i < mods.length; i++) {
    const count = mod_count[mods[i]] || 0
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

      switch_character(character_id)

      // allow collecting of items
      $('#item-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("collect_item", { id })
          .receive('ok', () => {
            // find entry in items and mark as collected
            window.item_table.cell($(this).parent()).data(true)

            let cell = window.character_table.cell(`#${window.character_id}`, 3)
            cell.data(cell.data() + 1).draw()

            const item = window.items.find(i => i.id == id)

            cell = window.display_table.cell(`#${item.display_id}`, 1)
            cell.data(cell.data() + 1).draw()

            cell = window.mod_table.cell(`#${item.mod_id}`, 3)
            cell.data(cell.data() + 1).draw()

            if (item.location_id) {
              cell = window.location_table.cell(`#${item.location_id}`, 1)
              cell.data(cell.data() + 1).draw()
            }

            if (item.quest_id) {
              cell = window.quest_table.cell(`#${item.quest_id}`, 1)
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

            let cell = window.character_table.cell(`#${window.character_id}`, 3)
            cell.data(cell.data() - 1).draw()

            const item = window.items.find(i => i.id == id)

            cell = window.display_table.cell(`#${item.display_id}`, 1)
            cell.data(cell.data() - 1).draw()

            cell = window.mod_table.cell(`#${item.mod_id}`, 3)
            cell.data(cell.data() - 1).draw()

            if (item.location_id) {
              cell = window.location_table.cell(`#${item.location_id}`, 1)
              cell.data(cell.data() - 1).draw()
            }
            if (item.quest_id) {
              cell = window.quest_table.cell(`#${item.quest_id}`, 1)
              cell.data(cell.data() - 1).draw()
            }
          })
      })

      // allow activating a different character
      $('#character-table').on('click', 'a.uncheck', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("activate_character", { id })
          .receive('ok', ({ info }) => {
            // update character table
            switch_character(id)
            Flash.info(info)
          })
          .receive('error', reason => Flash.error(reason))
      })

  //   // allow deleting of items
  //   if (window.admin) {
  //     $('#item-table').on('click', '.delete', function () {
  //       let id = parseInt($(this).closest('tr').attr('id'))
  //       channel.push("delete", { id })
  //     })
  //   }


  // if (window.moderator) {
  //   $('#modal form').submit(function (e) {
  //     e.preventDefault()

  //     const data = $(this).serializeArray().reduce(function(obj, item) {
  //       obj[item.name] = item.value;
  //       return obj;
  //     }, {})

  //     channel.push('add', data)
  //       .receive('ok', () => reset_modal())
  //       .receive('error', ({ errors }) => {
  //         for (var key in errors) {
  //           if (errors.hasOwnProperty(key)) {
  //             $(`#${key}`).addClass('is-invalid')
  //               .after(`<div class="invalid-feedback">${errors[key]}</div>`)
  //           }
  //         }
  //       })

  //   })
  // }

      // // add options to the add / update modal
      // add_options('#location_id', locations)
      // add_options('#quest_id', quests)
      // add_options('#display_id', displays)
      // add_options('#mod_id', mods)

      Menu.search('')
    })
    .receive("error", ({ reason }) => Flash.error(reason))
}

export default configure_user_channel
