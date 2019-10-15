import $ from 'jquery'
import { socket, join_user_channel } from '.'
import { Menu, Table } from '../utils'

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

// calculate item count for a given module and sets items_found to 0
const calculate_item_count = (items, entries, key) => {
  for (let i in entries) {
    if (entries.hasOwnProperty(i)) {
      if (window.user) entries[i].items_found = 0

      entries[i].items_found = 0
      items.forEach(item => {
        if (item[key] == entries[i].id) entries[i].item_count++
      })

      if (key == 'mod_id') {
        const mod_items = window.items.filter(item => item.mod_id == mods[i].id)
        entries[i].item_count = mod_items.length
      }
      else entries[i].item_count = 0
    }
  }
}

const configure_public_channel = () => {
  let channel = socket.channel("public")

  // listen for deleted items
  channel.on('add', ({ item }) => {
    window.item_table
      .row.add( item )
      .draw()
      .node()
  })
  channel.on('delete', ({ id }) => window.item_table.row(`#${id}`).remove().draw())

  channel.join()
    .receive("ok", params => {

      // user has joined already, do nothing...
      if (window.user != undefined) return

      const { displays, items, locations, mods, quests, user, moderator, admin } = params

      window.user = user
      window.moderator = moderator
      window.admin = admin

      window.displays = displays
      window.items = items
      window.locations = locations
      window.quests = quests
      window.mods = mods

      // add item.active = false to all items
      for (let i in items) {
        if (items.hasOwnProperty(i)) items[i].active = false
      }
      calculate_item_count(items, displays, 'display_id')
      calculate_item_count(items, locations, 'location_id')
      calculate_item_count(items, quests, 'quest_id')
      calculate_item_count(items, mods, 'mod_id')

      Table.item(items)
      Table.location(locations)
      Table.quest(quests)
      Table.display(displays)
      Table.mod(mods)

      Menu.search('')
      $('#loader-wrapper').addClass('d-none')

      if (user) join_user_channel(user)
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

export default configure_public_channel
