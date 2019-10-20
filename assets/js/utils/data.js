const list_characters = () => window.character_table.rows().data().toArray()
const list_character_options = () =>
  window.character_table.coumns(['id:name', 'name:name']).data().toArray()

const list_displays = () => window.display_table.rows().data().toArray()
const list_display_ids = () => window.display_table.rows().ids().toArray()
const list_display_options = () =>
  window.display_table.coumns(['id:name', 'name:name']).data().toArray()

const list_items = () => window.item_table.rows().data().toArray()
const list_item_ids = () => window.item_table.rows().ids().toArray()

const list_locations = () => window.location_table.rows().data().toArray()
const list_location_ids = () => window.location_table.rows().ids().toArray()

const list_mod_ids = () => window.mod_table.rows().ids().toArray()

const list_quests = () => window.quest_table.rows().data().toArray()
const list_quest_ids = () => window.quest_table.rows().ids().toArray()

// if character table was initialized show character item ids
const list_character_item_ids = (id = window.character_id) =>
  window.character_table.cell(`#${id}`, 'items:name').data()

// if character table was initialized show character mod ids
const list_character_mod_ids = (id = window.character_id) =>
  window.character_table.cell(`#${id}`, 'mods:name').data()

const get_item_count = (data, items, property) => {
  const count = {}
  for (let i = 0; i < items.length; i++) {
    if (items.hasOwnProperty(i) && items[i][property]) {
      count[items[i][property]] = count[items[i][property]]
        ? count[items[i][property]]++
        : 1
    }
  }

  // apply count to all locations / quests / mods / displays
  for (let i = 0; i < data.length; i++) {
    if (items.hasOwnProperty(i)) {
      data[i].found = 0
      data[i].count = count[data[i].id] || 0
    }
  }
  return data
}

const activate_character = (id = window.character_id) => {

  // prepare found and count for displays
  const display_found = {}, display_count = {}, display_ids = list_display_ids()
  for (let i = 0; i < display_ids.length; i++) {
    display_found[display_ids[i]] = 0
    display_count[display_ids[i]] = 0
  }

  // prepare found and count for mods
  const mod_found = {}, mod_count = {}, mod_ids = list_mod_ids()
  for (let i = 0; i < mod_ids.length; i++) {
    mod_found[mod_ids[i]] = 0
    mod_count[mod_ids[i]] = 0
  }

  // prepare found and count for locations
  const location_found = {}, location_count = {}, location_ids = list_location_ids()
  for (let i = 0; i < location_ids.length; i++) {
    location_found[location_ids[i]] = 0
    location_count[location_ids[i]] = 0
  }

  // prepare found and count for mods
  const quest_found = {}, quest_count = {}, quest_ids = list_quest_ids()
  for (let i = 0; i < quest_ids.length; i++) {
    quest_found[quest_ids[i]] = 0
    quest_count[quest_ids[i]] = 0
  }

  const items = list_items()
  const character_item_ids = list_character_item_ids(id)

  for (let i = 0; i < items.length; i++) {
    const item = items[i]

    // update item table: active state
    const active = character_item_ids.find(id => id == item.id) != undefined

    window.item_table.cell(`#${item.id}`, 'active:name').data(active).draw()

    // prepare found for displays, mods, locations, and quests
    if (active) {
      display_found[item.display_id]++
      mod_found[item.mod_id]++

      if (item.location_id) location_found[item.location_id]++
      if (item.quest_id) quest_found[item.quest_id]++
    }

    // prepare count for displays, mods, locations, and quests
    display_count[item.display_id]++
    mod_count[item.mod_id]++
    location_count[item.location_id]++
    quest_count[item.quest_id]++
  }

  // update display table
  for (let i = 0; i < display_ids.length; i++) {
    window.display_table
      .cell(`#${display_ids[i]}`, 'found:name').data(display_found[display_ids[i]])
      .cell(`#${display_ids[i]}`, 'count:name').data(display_count[display_ids[i]])
      .draw()
  }

  // update location table
  for (let i = 0; i < location_ids.length; i++) {
    window.location_table
      .cell(`#${location_ids[i]}`, 'found:name').data(location_found[location_ids[i]])
      .cell(`#${location_ids[i]}`, 'count:name').data(location_count[location_ids[i]])
      .draw()
  }

  // update quest table
  for (let i = 0; i < quest_ids.length; i++) {
    window.quest_table
      .cell(`#${quest_ids[i]}`, 'found:name').data(quest_found[quest_ids[i]])
      .cell(`#${quest_ids[i]}`, 'count:name').data(quest_count[quest_ids[i]])
      .draw()
  }

  // update mod table
  const character_mod_ids = list_character_mod_ids(id)
  for (let i = 0; i < mod_ids.length; i++) {
    const active = character_mod_ids.find(id => id == mod_ids[i]) != undefined
    window.mod_table
      .cell(`#${mod_ids[i]}`, 'active:name').data(active)
      .cell(`#${mod_ids[i]}`, 'found:name').data(mod_found[mod_ids[i]])
      .cell(`#${mod_ids[i]}`, 'count:name').data(mod_count[mod_ids[i]])
      .draw()
  }

  // show all user columns if still hidden, deactivate old active character
  if (!window.character_id) {
    window.item_table.column('active:name').visible(true).draw()
    window.display_table.column('found:name').visible(true).draw()
    window.location_table.column('found:name').visible(true).draw()
    window.mod_table.columns(['active:name', 'found:name']).visible(true).draw()
    window.quest_table.column('found:name').visible(true).draw()
  } else {
    window.character_table.cell(`#${window.character_id}`, 0).data(false).draw()
  }

  // set new character as active
  window.character_table.cell(`#${id}`, 0).data(true).draw()
  window.character_id = id
}

const activate_mod = id => {
  const character_mod_ids = list_character_mod_ids()
  character_mod_ids.push(id)
  window.character_table.cell(`#${window.character_id}`, 'items:name').data(character_mod_ids)
  window.mod_table.cell(`#${id}`, 'active:name').data(true).draw()
  activate_character()
}

const deactivate_mod = id => {
  const character_mod_ids = list_character_mod_ids()
  for( var i = 0; i < character_mod_ids.length; i++){
    if ( character_mod_ids[i] == id) character_mod_ids.splice(i, 1)
  }
  window.character_table.cell(`#${window.character_id}`, 'items:name').data(character_mod_ids)
  window.mod_table.cell(`#${id}`, 'active:name').data(false).draw()
  activate_character()
}

const collect_item = id => {
  // update tables
  window.item_table.cell(`#${id}`, 'active:name').data(true).draw()

  const item_ids = list_character_item_ids()
  item_ids.push(id)
  window.character_table.cell(`#${window.character_id}`, 'items:name').data(item_ids).draw()

  const item = window.item_table.row(`#${id}`).data()
  let found

  found = window.display_table.cell(`#${item.display_id}`, 'found:name').data()
  window.display_table.cell(`#${item.display_id}`, 'found:name').data(found + 1)

  if (item.location_id) {
    found = window.location_table.cell(`#${item.location_id}`, 'found:name').data()
    window.location_table.cell(`#${item.location_id}`, 'found:name').data(found + 1)
  }

  if (item.quest_id) {
    found = window.quest_table.cell(`#${item.quest_id}`, 'found:name').data()
    window.quest_table.cell(`#${item.quest_id}`, 'found:name').data(found + 1)
  }

  found = window.mod_table.cell(`#${item.mod_id}`, 'found:name').data()
  window.mod_table.cell(`#${item.mod_id}`, 'found:name').data(found + 1)
}

const remove_item = id => {
  const item_ids = list_character_item_ids()
  for( var i = 0; i < item_ids.length; i++){
    if ( item_ids[i] == id) item_ids.splice(i, 1)
  }

  // update tables
  let found
  const item = window.item_table.row(`#${id}`).data()

  window.item_table.cell(`#${id}`, 'active:name').data(false).draw()
  window.character_table.cell(`#${window.character_id}`, 'items:name').data(item_ids).draw()

  found = window.display_table.cell(`#${item.display_id}`, 'found:name').data()
  window.display_table.cell(`#${item.display_id}`, 'found:name').data(found - 1)

  if (item.location_id) {
    found = window.location_table.cell(`#${item.location_id}`, 'found:name').data()
    window.location_table.cell(`#${item.location_id}`, 'found:name').data(found - 1)
  }

  if (item.quest_id) {
    found = window.quest_table.cell(`#${item.quest_id}`, 'found:name').data()
    window.quest_table.cell(`#${item.quest_id}`, 'found:name').data(found - 1)
  }

  found = window.mod_table.cell(`#${item.mod_id}`, 'found:name').data()
  window.mod_table.cell(`#${item.mod_id}`, 'found:name').data(found - 1)
}

const add_character = character => {
  character.active = false
  character.found = 0
  character.count = 0
  window.character_table.row.add(character).draw()
}

export {
  activate_character,
  activate_mod,
  add_character,
  deactivate_mod,
  get_item_count,
  list_character_item_ids,
  list_character_mod_ids,
  list_items,
  collect_item,
  remove_item
}
