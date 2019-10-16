import $ from 'jquery'
import { socket, join_moderator_channel, join_user_channel } from '.'
import { Menu, Table, Flash } from '../utils'

// calculate item count for a given module and sets items_found to 0
export const calculate_item_counts = () => {
  items = Table.get('item').rows().data().toArray()

  const character_count = {}, display_count = {}, location_count = {}, mod_count = {}, quest_count = {}

  const characters = window.character_id ? Table.get('character').rows().data().toArray() : null

  for (let i in items) {
    if (items.hasOwnProperty(i)) {
      const item = items[i]

      // count characters
      if (characters) {
        for (let c in characters) {
          if (characters.hasOwnProperty(c)) {
            if (characters[c].mods.find(c => c == item.mod_id)) {
              if (character_count[characters[c].id]) character_count[characters[c].id]++
              else character_count[characters[c].id] = 1
            }
          }
        }
      }

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

  // update character table
  if (characters) {
    const c = Table.get('character').rows().ids().toArray()
    for (let i = 0; i < c.length; i++) {
      window.character_table.cell(`#${c[i]}`, 'count:name')
        .data(character_count[c[i]] || 0).draw()
    }
  }

  // update display table
  const d = Table.get('display').rows().ids().toArray()
  for (let i = 0; i < d.length; i++) {
    window.display_table.cell(`#${d[i]}`, 'count:name').data(display_count[d[i]] || 0).draw()
  }

  // update location table
  const locations = window.location_table.rows().ids().toArray()
  for (let i = 0; i < locations.length; i++) {
    window.location_table.cell(`#${locations[i]}`, 'count:name').data(location_count[locations[i]] || 0).draw()
  }

  // update quest table
  const quests = window.quest_table.rows().ids().toArray()
  for (let i = 0; i < quests.length; i++) {
    window.quest_table.cell(`#${quests[i]}`, 'count:name').data(quest_count[quests[i]] || 0).draw()
  }

  // update mod table
  const mods = window.mod_table.rows().ids().toArray()
  for (let i = 0; i < mods.length; i++) {
    window.mod_table.cell(`#${mods[i]}`, 'count:name').data(mod_count[mods[i]] || 0).draw()
  }
}

const configure_public_channel = () => {
  let channel = socket.channel("public")

  // listen for events
  channel.on('add-item', ({ item }) => {
    window.item_table.row.add(item).draw().node()
    calculate_item_counts()
  })

  channel.on('delete-item', ({ id }) => {
    window.item_table.row(`#${id}`).remove().draw()
    calculate_item_counts()
  })

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

      Table.item(items)
      Table.location(locations)
      Table.quest(quests)
      Table.display(displays)
      Table.mod(mods)

      calculate_item_counts()

      Menu.search('')
      $('#loader-wrapper').addClass('d-none')

      if (user) join_user_channel(user)
      if (moderator) join_moderator_channel()
    })
    .receive("error", ({reason}) => Flash.error(reason))
}

export default configure_public_channel
