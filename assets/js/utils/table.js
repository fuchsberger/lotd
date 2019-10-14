import $ from 'jquery'

const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: [[0, 'asc']],
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 'id'
}

const cell_name = d => (d.url ? `<a href="${d.url}" target='_blank'>${d.name}</a>` : d.name)

const icon = name => `<i class="icon-${name}"></i>`

const manage_actions = () => {
  const edit = `<a class='icon-pencil'></a>`
  const del = `<a class='delete text-danger'><i class='icon-cancel'</a>`

  if (window.moderator && window.admin) return edit + del
  else if (window.moderator) return edit
  else if (window.admin) return del
  else return ''
}

const user_actions = found => (
  found
    ? `<a class='remove'>${icon('ok-squared')}</a>`
    : `<a class='collect'>${icon('plus-squared-alt')}</a>`
)

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
  let columns = [
    {
      title: "Character",
      className: "all font-weight-bold",
      data: 'name'
    },
    { title: "Items Found", data: 'items_found' }
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
    columns
  })
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
  // if (window.user) {

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

  //   // add collect / borrow column
  //   columns.splice(0, 0, {
  //     className: "all small-cell",
  //     render: found => user_actions(found),
  //     searchable: false,
  //     sortable: false,
  //     title: icon('ok-squared'),
  //     width: "25px"
  //   })
  // }

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
    // order: [[window.user ? 1 : 0, 'asc']],
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
    // { title: "Items Total", data: 3 }
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
  let columns = [
    {
      title: "Mod",
      className: "all font-weight-bold",
      data: null,
      render: mod => cell_name(mod)
    }
  ]

  // add control columns
  add_control_columns(columns)

  window.mod_table = $('#mod-table').DataTable({
    ...TABLE_DEFAULTS,
    data: mods,
    columns
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
    // { title: "Quests Total", data: 3 }
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
  let columns = [
    {
      title: "Display",
      className: "all font-weight-bold",
      data: null,
      render: display => cell_name(display)
    },
    // { title: "Quests Total", data: 3 }
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
