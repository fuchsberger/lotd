import $ from 'jquery'

const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: [[0, 'asc']],
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 'id'
}

const cell_check = active => (
  active
    ? `<a class='check'>${icon('ok-squared')}</a>`
    : `<a class='uncheck'>${icon('plus-squared-alt')}</a>`
)

const cell_name = d => (d.url ? `<a href="${d.url}" target='_blank'>${d.name}</a>` : d.name)

const cell_time = t => `<time datetime='${t}'></time`

const icon = name => `<i class="icon-${name}"></i>`

const manage_actions = () => {
  const edit = `<a class='icon-pencil'></a>`
  const del = `<a class='delete text-danger'><i class='icon-cancel'</a>`

  if (window.moderator && window.admin) return edit + del
  else if (window.moderator) return edit
  else if (window.admin) return del
  else return ''
}



const add_control_columns = columns => {

  // if moderator, add action column
  // if (moderator || admin) columns.push({
  //   className: 'text-center small-cell',
  //   data: 0,
  //   render: id => manage_actions(id),
  //   searchable: false,
  //   orderable: false,
  //   title: 'Actions'
  // })

  columns.push({
    className: 'control all small-cell',
    data: null,
    defaultContent: '',
    orderable: false
  })
}

const add_options = (selector, entries) => {
  for (let i in entries) {
    if(entries.hasOwnProperty(i))
      $(selector).append(`<option value='${entries[i].id}'>${entries[i].name}</option>`)
  }
}

const character = characters => {
  // calculate found items and item count
  for (let i in characters) {
    if (characters.hasOwnProperty(i)) {

      characters[i].active = window.character_id == characters[i].id

      characters[i].item_count = 0
      const active_mods = window.character_mods.concat([1,2,3,4,5])
      window.items.forEach(item => {
        if(active_mods.find(m => m == item.mod_id)) characters[i].item_count++
      })
    }
  }

  let columns = [
    {
      title: icon('star'),
      className: "all small-cell",
      data: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
    },
    {
      title: "Character",
      className: "all font-weight-bold",
      data: 'name'
    },
    { title: "Mods", data: 'mods', render: mods => mods.length + 5, searchable: false },
    { title: "Items Found", data: 'items', render: items => items.length, searchable: false },
    { title: "Items Total", data: 'item_count', searchable: false },
    {
      title: "Created",
      data: 'created',
      render: t => cell_time(t)
    },
  ]

  // add control columns
  add_control_columns(columns)

  // allow deleting of items
  // if (window.moderator) {
  //   $('#location-table').on('click', '.delete', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("delete", { id })
  //   })
  // }

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
      title: "Item",
      className: "all font-weight-bold",
      data: null,
      sort: item => item.name,
      render: item => cell_name(item)
    },
    { data: 'location_id', title: "Location", render: id => cell_link('location', id) },
    { data: 'quest_id', title: "Quest", render: id => cell_link('quest', id) },
    { data: 'display_id', title: "Display", render: id => cell_link('display', id) }
  ]

  // add control columns
  add_control_columns(columns)

  // user was logged in, add collect column
  if (window.user) {

    // add active state to data
    for (let i in window.items) {
      if (window.items.hasOwnProperty(i)) {
        window.items[i].active =
          window.character_items.find(j => j == window.items[i].id) != undefined
      }
    }

  //   // allow collecting of items
  //   $('#item-table').on('click', '.collect', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("collect", { id })
  //       .receive('ok', () => {
  //         // find entry in items and mark as collected
  //         $('#item-table').DataTable().cell($(this).parent()).data(true)
  //       })
  //   })

  //   // allow borrowing of items
  //   $('#item-table').on('click', '.remove', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("remove", { id })
  //       .receive('ok', () => {
  //         // find entry in items and mark as collected
  //         $('#item-table').DataTable().cell($(this).parent()).data(false)
  //       })
  //   })

  //   // allow deleting of items
  //   if (window.admin) {
  //     $('#item-table').on('click', '.delete', function () {
  //       let id = parseInt($(this).closest('tr').attr('id'))
  //       channel.push("delete", { id })
  //     })
  //   }

    // add collect / borrow column
    columns.splice(0, 0, {
      className: "all small-cell",
      data: 'active',
      render: active => cell_check(active),
      searchable: false,
      sortable: false,
      title: icon('ok-squared')
    })
  }

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

  window.item_table = $('#item-table').DataTable({
    ...TABLE_DEFAULTS,
    data: items,
    order: [[window.user ? 1 : 0, 'asc']],
    columns
  })
}

const location = locations => {
  // calculate found items and item count
  for (let i in locations) {
    if (locations.hasOwnProperty(i)) {
      locations[i].items_found = 0
      locations[i].item_count = 0

      window.items.forEach(item => {
        if (item.quest_id == locations[i].id) {
          locations[i].item_count++
          if(window.character_items.find(j => j == item.id)) locations[i].items_found++
        }
      })
    }
  }

  let columns = [
    {
      title: "Location",
      className: "all font-weight-bold",
      data: null,
      render: location => cell_name(location)
    },
    { title: 'Items Found', data: 'items_found', searchable: false  },
    { title: 'Items Total', data: 'item_count', searchable: false  }
  ]

  // users that are logged in should see the items found column
  // if (user) columns.splice(1, 0, {
  //   data: 4,
  //   searchable: false,
  //   title: "Items Found",
  // })

  // add control columns
  add_control_columns(columns)

  // allow deleting of items
  // if (window.moderator) {
  //   $('#location-table').on('click', '.delete', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("delete", { id })
  //   })
  // }

  window.location_table = $('#location-table').DataTable({
    ...TABLE_DEFAULTS,
    data: locations,
    columns
  })
}

const mod = mods => {

  // calculate found items and item count
  for (let i in mods) {
    if (mods.hasOwnProperty(i)) {
      mods[i].active =
        mods[i].id <= 5 || window.character_mods.find(m => m.id == mods[i].id) != undefined

      const mod_items = window.items.filter(item => item.mod_id == mods[i].id)
      mods[i].item_count = mod_items.length

      mods[i].items_found = 0
      window.character_items.forEach(j => {
        if(mod_items.find(item => item.id == j)) mods[i].items_found++
      })
    }
  }

  let columns = [
    {
      title: icon('ok-squared'),
      className: "all small-cell",
      data: null,
      render: d => d.id <= 5 ? icon('ok-squared') : cell_check(d.active),
      searchable: false,
      sortable: false
    },
    {
      title: "Mod",
      className: "all font-weight-bold",
      data: null,
      render: mod => cell_name(mod)
    },
    { title: 'Filename', data: 'filename'},
    { title: 'Items Found', data: 'items_found', searchable: false  },
    { title: 'Items Total', data: 'item_count', searchable: false  }
  ]

  // add control columns
  add_control_columns(columns)

  window.mod_table = $('#mod-table').DataTable({
    ...TABLE_DEFAULTS,
    data: mods,
    columns,
    order: [[1, 'asc']]
  })
}

const quest = quests => {
  // calculate found items and item count
  for (let i in quests) {
    if (quests.hasOwnProperty(i)) {
      quests[i].items_found = 0
      quests[i].item_count = 0

      window.items.forEach(item => {
        if (item.quest_id == quests[i].id) {
          quests[i].item_count++
          if(window.character_items.find(j => j == item.id)) quests[i].items_found++
        }
      })
    }
  }

  let columns = [
    {
      title: "Quest",
      className: "all font-weight-bold",
      data: null,
      render: quest => cell_name(quest)
    },
    { title: 'Items Found', data: 'items_found', searchable: false  },
    { title: 'Items Total', data: 'item_count', searchable: false  }
  ]

  // users that are logged in should see the items found column
  // if (user) columns.splice(1, 0, {
  //   data: 4,
  //   searchable: false,
  //   title: "Items Found",
  // })

  // add control columns
  add_control_columns(columns)

  // allow deleting of items
  // if (window.moderator) {
  //   $('#location-table').on('click', '.delete', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("delete", { id })
  //   })
  // }

  window.quest_table = $('#quest-table').DataTable({
    ...TABLE_DEFAULTS,
    data: quests,
    columns
  })
}

const display = displays => {
  // calculate found items and item count
  for (let i in displays) {
    if (displays.hasOwnProperty(i)) {
      displays[i].items_found = 0
      displays[i].item_count = 0

      window.items.forEach(item => {
        if (item.display_id == displays[i].id) {
          displays[i].item_count++
          if(window.character_items.find(j => j == item.id)) displays[i].items_found++
        }
      })
    }
  }

  let columns = [
    {
      title: "Display",
      className: "all font-weight-bold",
      data: null,
      render: display => cell_name(display)
    },
    { title: 'Items Found', data: 'items_found', searchable: false  },
    { title: 'Items Total', data: 'item_count', searchable: false  }
  ]

  // users that are logged in should see the items found column
  // if (user) columns.splice(1, 0, {
  //   data: 4,
  //   searchable: false,
  //   title: "Items Found",
  // })

  // add control columns
  add_control_columns(columns)

  // allow deleting of items
  // if (window.moderator) {
  //   $('#location-table').on('click', '.delete', function () {
  //     let id = parseInt($(this).closest('tr').attr('id'))
  //     channel.push("delete", { id })
  //   })
  // }

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
