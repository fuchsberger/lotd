import $ from 'jquery'
import { Data } from '.';

// customize default search behavior
$.fn.dataTable.ext.search.push(
  function (settings, data) {

    if (!window.character_id) return true

    switch (window.page) {
      case 'item':
      case 'location':
      case 'quest':
        // find character_mods
        const character_mods = Data.character_mods()

        // check if mod_id of item/quest/location under character_mods
        const column = settings.aoColumns.find(c => c.name == 'mod_id')
        return column && character_mods.find(m => m == data[column.idx])

      default: return true
    }
  }
);

const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: [[0, 'asc']],
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 'id'
}

const icon = name => `<i class="icon-${name}"></i>`

const cell_check = active => (
  active
    ? `<a class='check'>${icon('ok-squared')}</a>`
    : `<a class='uncheck'>${icon('plus-squared-alt')}</a>`
)

const cell_name = d => (d.url ? `<a href="${d.url}" target='_blank'>${d.name}</a>` : d.name)

const cell_time = t => `<time datetime='${t}'></time`

const get = name => {
  switch (name) {
    case 'item': return window.item_table
    case 'display': return window.display_table
    case 'mod': return window.mod_table
    case 'quest': return window.quest_table
    case 'location': return window.location_table
    case 'character': return window.character_table
    case 'user': return window.user_table
  }
}

const ACTIVE_COLUMN = [{
  className: "all small-cell",
  data: 'active',
  name: 'active',
  render: active => cell_check(active),
  searchable: false,
  sortable: false,
  title: icon('ok-squared'),
  visible: false
}]

const ITEM_COLUMNS = [
  { title: 'Items Found', data: 'found', name: 'found', searchable: false, visible: false },
  { title: 'Items Total', data: 'count', name: 'count', searchable: false }
]

const MODERATOR_COLUMN = [{
  className: 'all small-cell',
  defaultContent: `<a class='icon-pencil'></a>`,
  name: 'edit',
  orderable: false,
  sortable: false,
  title: icon('pencil'),
  visible: false
}]

const CONTROL_COLUMN = [{
  className: 'control all small-cell',
  defaultContent: '',
  orderable: false,
  sortable: false,
  width: '25px'
}]

const character = characters => {
  let columns = [
    ...ACTIVE_COLUMN,
    { title: "Character", className: "all font-weight-bold", data: 'name'},
    {
      title: "Mods",
      data: 'mods',
      name: 'mods',
      render: mods => mods.length,
      searchable: false
    },
    {
      title: "Items Found",
      data: 'items',
      name: 'items',
      render: items => items.length,
      searchable: false
    },
    { title: "Items Total", data: 'count', name: 'count', searchable: false },
    { title: "Created", data: 'created', render: t => cell_time(t) },
    ...CONTROL_COLUMN
  ]
  columns[0].visible = true

  window.character_table = $('#character-table').DataTable({
    ...TABLE_DEFAULTS,
    data: characters,
    columns,
    order: [[3, 'desc']]
  })

  window.character_table.on( 'draw', () => $('time').timeago())
}

const display = displays => {
  let columns = [
    {
      title: "Display",
      className: "all font-weight-bold",
      data: 'name',
      name: 'name',
      render: (_name, _type, display) => cell_name(display)
    },
    ...ITEM_COLUMNS,
    ...MODERATOR_COLUMN,
    ...CONTROL_COLUMN
  ]
  window.display_table =
    $('#display-table').DataTable({ ...TABLE_DEFAULTS, data: displays, columns })
}

const item = items => {

  const cell_link = (type, id) =>
    (id ? `<a class='search-field'>${get(type).cell(`#${id}`, 'name:name').data()}</a>` : '')

  let columns = [
    ...ACTIVE_COLUMN,
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
    { data: 'mod_id', name: 'mod_id', visible: false },
    { data: 'mod_id', title: 'Mod', name: 'mod', render: id => cell_link('mod', id) },
    ...MODERATOR_COLUMN,
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
      data: 'name',
      name: 'name',
      render: (_name, _type, location) => cell_name(location)
    },
    { data: 'mod_id', name: 'mod_id', visible: false },
    ...ITEM_COLUMNS,
    ...MODERATOR_COLUMN,
    ...CONTROL_COLUMN
  ]
  window.location_table =
    $('#location-table').DataTable({ ...TABLE_DEFAULTS, data: locations, columns })
}


const mod = mods => {
  let columns = [
    ...ACTIVE_COLUMN,
    {
      title: "Mod",
      className: "all font-weight-bold",
      data: 'name',
      name: 'name',
      render: (_name, _type, mod) => cell_name(mod)
    },
    { title: 'Filename', data: 'filename'},
    ...ITEM_COLUMNS,
    ...MODERATOR_COLUMN,
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
      data: 'name',
      name: 'name',
      render: (_name, _type, quests) => cell_name(quests)
    },
    { data: 'mod_id', name: 'mod_id', visible: false },
    ...ITEM_COLUMNS,
    ...MODERATOR_COLUMN,
    ...CONTROL_COLUMN
  ]
  window.quest_table = $('#quest-table').DataTable({ ...TABLE_DEFAULTS, data: quests, columns })
}

export { character, display, get, item, location, mod, quest }
