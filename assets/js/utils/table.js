import $ from 'jquery'

const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: [[0, 'asc']],
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 'id'
}

const icon = name => `<i class="icon-${name}"></i>`

const CONTROL_COLUMN = [{
  className: 'control all small-cell',
  defaultContent: `<a class='icon-pencil'></a>`,
  orderable: false,
  sortable: false,
  title: icon('pencil'),
  visible: false
}]

const cell_check = active => (
  active
    ? `<a class='check'>${icon('ok-squared')}</a>`
    : `<a class='uncheck'>${icon('plus-squared-alt')}</a>`
)

const cell_name = d => (d.url ? `<a href="${d.url}" target='_blank'>${d.name}</a>` : d.name)

const cell_time = t => `<time datetime='${t}'></time`

const character = characters => {
  let columns = [
    {
      title: icon('star'),
      className: "all small-cell",
      data: 'active',
      name: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
    },
    { title: "Character", className: "all font-weight-bold", data: 'name'},
    { title: "Mods", data: 'mods', name: 'mods', render: mods => mods.length, searchable: false },
    {
      title: "Items Found",
      data: 'items',
      name: 'items',
      render: items => items.length,
      searchable: false
    },
    { title: "Items Total", data: 'item_count', searchable: false },
    { title: "Created", data: 'created', render: t => cell_time(t) },
    ...CONTROL_COLUMN
  ]

  window.character_table = $('#character-table').DataTable({
    ...TABLE_DEFAULTS,
    data: characters,
    columns,
    order: [[3, 'desc']]
  })

  window.character_table.on( 'draw', () => $('time').timeago())
}

const item = items => {

  const cell_link = (type, id) => {
    if (!id) return ''
    let data
    switch (type) {
      case 'location': data = window.locations; break;
      case 'quest': data = window.quests; break;
      case 'display': data = window.displays; break;
    }
    return `<a class='search-field'>${data.find(i => i.id == id).name}</a>`
  }

  let columns = [
    {
      className: "all small-cell",
      data: 'active',
      name: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
      title: icon('ok-squared'),
      visible: false
    },
    {
      title: "Item",
      className: "all font-weight-bold",
      data: null,
      sort: item => item.name,
      render: item => cell_name(item)
    },
    { data: 'location_id', title: "Location", render: id => cell_link('location', id) },
    { data: 'quest_id', title: "Quest", render: id => cell_link('quest', id) },
    { data: 'display_id', title: "Display", render: id => cell_link('display', id) },
    { data: 'mod_id', name: 'mod', sortable: false, visible: false },
    ...CONTROL_COLUMN
  ]

  window.item_table = $('#item-table').DataTable({
    ...TABLE_DEFAULTS,
    data: items,
    order: [[1, 'asc']],
    columns
  })
}

const location = locations => {
  let columns = [
    {
      title: "Location",
      className: "all font-weight-bold",
      data: null,
      render: location => cell_name(location)
    },
    {
      title: 'Items Found',
      name: 'found',
      data: 'items_found',
      searchable: false,
      visible: false
    },
    { title: 'Items Total', data: 'item_count', searchable: false },
    { data: 'mod_id', name: 'mod', sortable: false, visible: false },
    ...CONTROL_COLUMN
  ]

  window.location_table = $('#location-table').DataTable({
    ...TABLE_DEFAULTS,
    data: locations,
    columns
  })
}

const mod = mods => {
  let columns = [
    {
      title: icon('ok-squared'),
      className: "all small-cell",
      data: 'active',
      name: 'active',
      render: (active, undefined, d) => d.id <= 5 ? icon('ok-squared') : cell_check(active),
      searchable: false,
      sortable: false,
      visible: false
    },
    {
      title: "Mod",
      className: "all font-weight-bold",
      data: null,
      render: mod => cell_name(mod)
    },
    { title: 'Filename', data: 'filename'},
    {
      title: 'Items Found',
      name: 'found',
      data: 'items_found',
      searchable: false,
      visible: false
    },
    { title: 'Items Total', data: 'item_count', searchable: false },
    // { data: 'mod_id', name: 'mod', sortable: false, visible: false },
    ...CONTROL_COLUMN
  ]

  window.mod_table = $('#mod-table').DataTable({
    ...TABLE_DEFAULTS,
    data: mods,
    columns,
    order: [[1, 'asc']]
  })
}

const quest = quests => {

  let columns = [
    {
      title: "Quest",
      className: "all font-weight-bold",
      data: null,
      render: quest => cell_name(quest)
    },
    {
      title: 'Items Found',
      name: 'found',
      data: 'items_found',
      searchable: false,
      visible: false
    },
    { title: 'Items Total', data: 'item_count', searchable: false },
    { data: 'mod_id', name: 'mod', sortable: false, visible: false },
    ...CONTROL_COLUMN
  ]

  window.quest_table = $('#quest-table').DataTable({
    ...TABLE_DEFAULTS,
    data: quests,
    columns
  })
}

const display = displays => {
  let columns = [
    {
      title: "Display",
      className: "all font-weight-bold",
      data: null,
      render: display => cell_name(display)
    },
    {
      title: 'Items Found',
      name: 'found',
      data: 'items_found',
      searchable: false,
      visible: false
    },
    { title: 'Items Total', data: 'item_count', searchable: false },
    ...CONTROL_COLUMN
  ]

  window.display_table = $('#display-table').DataTable({
    ...TABLE_DEFAULTS,
    data: displays,
    columns
  })
}

export {
  character,
  display,
  item,
  location,
  mod,
  quest
}
