import $ from 'jquery'
import { Data } from '.';
import * as Menu from './menu'

// customize default search behavior
$.fn.dataTable.ext.search.push(
  function (settings, data) {

    if (!window.character_id) return true

    switch (window.page) {
      case 'item':
      case 'location':
      case 'quest':
        // check if mod_id of item/quest/location under character_mod_ids
        const column = settings.aoColumns.find(c => c.name == 'mod_id')
        return column && Data.list_character_mod_ids().find(id => id == data[column.idx])

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

const destroy_old_table = () => {
  if (window.table) {
    window.table.destroy();
    $('table').empty()
  }
}

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
  data: 'id',
  name: 'id',
  render: () => '',
  searchable: false,
  sortable: false,
  width: '25px'
}]

const character = characters => {

  // calculate item counts
  const items = Data.list_items()
  for (let i in characters) {
    if (characters.hasOwnProperty(i)) {
      characters[i].active = window.character_id == characters[i].id
      characters[i].count = 0
      items.forEach(item => {
        if(characters[i].mods.find(m => m == item.mod_id)) characters[i].count++
      })
    }
  }

  let columns = [
    {
      className: "all small-cell",
      data: 'active',
      name: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
      title: icon('ok-squared')
    },
    { title: "Character", className: "all font-weight-bold", data: 'name', name: 'name' },
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
    ...MODERATOR_COLUMN,
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

const display = (displays) => {

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
  const search_field = name => name ? `<a class='search-field'>${name}</a>` : ''

  let columns = [
    {
      className: "all small-cell",
      data: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
      title: icon('ok-squared'),
      visible: !!window.userToken
    },
    {
      title: "Item",
      className: "all font-weight-bold",
      data: null,
      sort: item => item.name,
      render: item => cell_name(item)
    },
    { data: 'location', title: "Location", render: l => search_field(l) },
    { data: 'quest', title: "Quest", render: q => search_field(q) },
    { data: 'display', title: "Display", render: d => search_field(d) },
    { data: 'mod', title: 'Mod', render: m => search_field(m) },
    ...MODERATOR_COLUMN,
    ...CONTROL_COLUMN
  ]

  // destroy old table before creating new one
  destroy_old_table()

  window.table = $('table').DataTable({
    ...TABLE_DEFAULTS,
    data: items,
    order: [[1, 'asc']],
    columns
  })

  ready()
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
    {
      title: 'Items Found',
      data: 'found',
      name: 'found',
      searchable: false,
      visible: window.user_id != false
    },
    {
      title: 'Items Total',
      data: 'count',
      name: 'count',
      searchable: false
    },
    ...MODERATOR_COLUMN,
    ...CONTROL_COLUMN
  ]

  // destroy old table before creating new one
  destroy_old_table()
  window.table = $('table').DataTable({ ...TABLE_DEFAULTS, data: locations, columns })
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

const ready = () => {
  $('#search').attr('disabled', false).siblings('.input-group-append').removeClass('d-none')
  $('#about').addClass('d-none')
  $('table').removeClass('d-none')
  Menu.search()
}

const user = users => {
  const columns = [
    {
      title: "Name",
      className: "all font-weight-bold",
      data: 'nexus_name',
      name: 'name',
      render: (name, _type, u) =>
        `<a href='https://www.nexusmods.com/users/${u.nexus_id}' target='_blank'>${name}</a>`
    },
    {
      title: "Roles",
      data: null,
      render: u => ((u.admin ? "Admin " : "") + " " + (u.moderator ? "Moderator" : ""))
    },
    { title: "Joined", data: 'created', render: t => cell_time(t), searchable: false },
    {
      className: 'small-cell',
      data: 'admin',
      name: 'admin',
      searchable: false,
      sortable: false,
      title: icon('user-plus'),
      render: admin => (
        admin
          ? `<a class='demote-admin icon-user-times' title='Demote Admin'></a>`
          : `<a class='promote-admin icon-user-plus' title='Promote Admin'></a>`
      )
    },
    {
      className: 'small-cell',
      data: 'moderator',
      name: 'moderator',
      searchable: false,
      sortable: false,
      title: icon('user-plus'),
      render: moderator => (moderator
        ? `<a class='demote-moderator icon-user-times text-success' title='Demote Moderator'></a>`
        : `<a class='promote-moderator icon-user-plus text-success' title='Promote Moderator'></a>`
      )
    },
    ...CONTROL_COLUMN
  ]

  // destroy old table before creating new one
  destroy_old_table()

  window.table = $('table').DataTable({...TABLE_DEFAULTS, data: users, columns })
  window.table.on('draw', () => $('time').timeago())

  ready()
}

export { character, display, get, item, location, mod, quest, user }
