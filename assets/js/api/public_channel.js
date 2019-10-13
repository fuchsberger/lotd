import $ from 'jquery'
import socket from './socket'
import { Menu } from '../utils'

const TABLE_DEFAULTS = {
  dom: 't',
  info: false,
  order: 0,
  paging: false,
  responsive: { details: { type: 'column', target: -1 } },
  rowId: 0
}

const cell_name = d => (d.url ? `<a href="${d.url}" target='_blank'>${d.name}</a>` : d.name)

const icon = name => `<span class="icon"><i class="icon-${name}"></i></span>`

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
const initialize_item_table = items => {

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


const initialize_location_table = (locations) => {
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

const initialize_quest_table = quests => {
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
    .receive("ok", ({ displays, items, locations, quests, user, moderator, admin }) => {

      window.user = user
      window.moderator = moderator
      window.admin = admin

      window.displays = displays
      window.items = items
      window.locations = locations
      window.quests = quests


      initialize_item_table(items)
      initialize_location_table(locations)
      initialize_quest_table(quests)

      Menu.search('')

      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

}

export default configure_public_channel
