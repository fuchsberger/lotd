import $ from 'jquery'
import socket from './socket'


const enableTableFeatures = table => {

  // initially update the item count
  let info = table.page.info()
  $('#search-count').text(info.recordsDisplay)

  table.on('draw.dt', function () {
    // update filtered count
    let info = table.page.info()
    $('#search-count').text(info.recordsDisplay)
  })

  // enable filtering tables based on a searchfield
  table.on('click', 'a.search-field', function () {
    const text = $(this).text()
    $('#search').val(text)
    toggle_search_cancel(true)
    $('table').DataTable().search(text).draw()
  })

  // enable searching/filtering
  $('#search').on('keyup', function () {
    toggle_search_cancel(this.value != '')
    table.search(this.value).draw()
  })

  // enable canceling a search
  $('#search-control .icon-cancel').on('click', () => {
    $('#search').val('')
    table.search('').draw()
    toggle_search_cancel(false)
  })
}

const icon = name => `<span class="icon"><i class="icon-${name}"></i></span>`

const search_field = term => (term ? `<a class='search-field'>${term}</a>` : '')

const manage_actions = (moderator, admin) => {
  const edit = `<a class='icon-pencil'></a>`
  const del = `<a class='delete text-danger'><i class='icon-cancel'</a>`

  if (moderator && admin) return edit + del
  else if (moderator) return edit
  else if (admin) return del
  else return ''
}

const user_actions = found => (
  found
    ? `<a class='remove'>${icon('ok-squared')}</a>`
    : `<a class='collect'>${icon('plus-squared-alt')}</a>`
)

const add_control_columns = (columns, moderator, admin) => {

  // if moderator, add action column
  if (moderator || admin) columns.push({
    className: 'text-center small-cell',
    data: 0,
    render: id => manage_actions(id, moderator, admin),
    searchable: false,
    orderable: false,
    title: 'Actions'
  })

  columns.push({
    className: 'control all small-cell',
    data: null,
    defaultContent: '',
    orderable: false
  })
}
const initialize_item_table = (items, user, moderator, admin) => {
  let columns = [
    {
      title: "Item", className: "all font-weight-bold", data: null, render: d => (
        d[2] ? `<a href="${d[2]}" target='_blank'>${d[1]}</a>` : d[1]
    )},
    { title: "Location", data: 3, render: d => search_field(d)},
    { title: "Quest", data: 4, render: d => search_field(d)},
    { title: "Display", data: 5, render: d => search_field(d) },
  ]

  // add control columns
  add_control_columns(columns, moderator, admin)

  // user was logged in, add collect column
  if (user) {

    // allow collecting of items
    $('#item-table').on('click', '.collect', function () {
      let id = parseInt($(this).closest('tr').attr('id'))
      channel.push("collect", { id })
        .receive('ok', () => {
          // find entry in items and mark as collected
          $('#item-table').DataTable().cell($(this).parent()).data(true)
        })
    })

    // allow borrowing of items
    $('#item-table').on('click', '.remove', function () {
      let id = parseInt($(this).closest('tr').attr('id'))
      channel.push("remove", { id })
        .receive('ok', () => {
          // find entry in items and mark as collected
          $('#item-table').DataTable().cell($(this).parent()).data(false)
        })
    })

    // allow deleting of items
    if (moderator) {
      $('#item-table').on('click', '.delete', function () {
        let id = parseInt($(this).closest('tr').attr('id'))
        channel.push("delete", { id })
      })
    }

    // add collect / borrow column
    columns.splice(0, 0, {
      className: "all small-cell",
      render: found => user_actions(found),
      searchable: false,
      sortable: false,
      title: icon('ok-squared'),
      width: "25px"
    })
  }

  if (moderator) {
    $('#modal form').submit(function (e) {
      e.preventDefault()

      const data = $(this).serializeArray().reduce(function(obj, item) {
        obj[item.name] = item.value;
        return obj;
      }, {})

      channel.push('add', data)
        .receive('ok', () => reset_modal())
        .receive('error', ({ errors }) => {
          for (var key in errors) {
            if (errors.hasOwnProperty(key)) {
              $(`#${key}`).addClass('is-invalid')
                .after(`<div class="invalid-feedback">${errors[key]}</div>`)
            }
          }
        })

    })
  }

  window.item_table = $('#item-table').DataTable({
    data: items,
    dom: 't',
    paging: false,
    info: false,
    order: [[user ? 1 : 0, 'asc']],
    responsive: {
      details: {
        type: 'column',
        target: -1
      }
    },
    rowId: 0,
    columns
  })

  enableTableFeatures(window.item_table)
}


const initialize_location_table = (locations, moderator, admin) => {
  let columns = [
    {
      title: "Location", className: "all font-weight-bold", data: null, render: d => (
        d[2] ? `<a href="${d[2]}" target='_blank'>${d[1]}</a>` : d[1]
    )},
    { title: "Items Found", data: 4 },
    { title: "Items Total", data: 3 }
  ]

  // add control columns
  add_control_columns(columns, moderator, admin)

  // allow deleting of items
  if (moderator) {
    $('#location-table').on('click', '.delete', function () {
      let id = parseInt($(this).closest('tr').attr('id'))
      channel.push("delete", { id })
    })
  }

  window.location_table = $('#location-table').DataTable({
    data: locations,
    dom: 't',
    paging: false,
    info: false,
    order: 0,
    responsive: { details: { type: 'column', target: -1 } },
    rowId: 0,
    columns
  })

  enableTableFeatures(window.location_table)
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
    .receive("ok", ({ items, locations, user, moderator, admin }) => {

      initialize_item_table(items, user, moderator, admin)
      initialize_location_table(locations, moderator, admin)

      $('#loader-wrapper').addClass('d-none')
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

}

export default configure_public_channel
