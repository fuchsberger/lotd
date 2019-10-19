import * as Table from './table'

const character_mods = (id = window.character_id) => {
  const character = window.character_table.row(`#${id}`).data()
  return character ? character.mods : null
}

// calculate item count for a given module and sets items_found to 0
const calculate_item_counts = () => {
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

export { character_mods, calculate_item_counts, update_character }
