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
  // window.character_mods = window.characters.find(c => c.id == id).mods

  // update character table
  if (window.character_id)
    window.character_table.cell(`#${window.character_id}`, 0).data(false).draw()
  window.character_table.cell(`#${id}`, 0).data(true).draw()

  // update items table

  // update mods table

  // update display table

  // update more tables...

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
          characters[i].found_items = characters[i].items.length
          characters[i].item_count = 0

          const active_mods = characters[i].mods.concat([1,2,3,4,5])
          window.items.forEach(item => {
            if(active_mods.find(m => m == item.mod_id)) characters[i].item_count++
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
