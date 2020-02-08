import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {

  mount() {
    super.mount()

    const table_elm = $('#item-table')
    const authenticated = table_elm.data('authenticated')

    // account for extra column when authenticated
    let columns = [
      { data: 0, name: "id", searchable: false, orderable: false, visible: false },
      {
        data: 1,
        name: "name",
        title: "Name",
        render: (name, _type, row) => row[2]
          ? `<strong><a class='text-body' href='${row[2]}' target='_blank'>${name}</a></strong>`
          : `<strong>${name}</strong>`
      },
      {
        data: "5.1",
        name: "location",
        title: "Location",
        render: (location, _type, row) => row[5][2]
          ? `<a class='text-body' href='${row[5][2]}' target='_blank'>${location}</a>`
          : location
      },
      {
        data: "3.1",
        name: "room",
        visible: false
      },
      {
        data: "4.1",
        name: "display",
        title: "Display",
        render: (display, _type, row) => {
          const tooltip_icon =
            `<i class='icon-home' data-placement='left' data-toggle='tooltip' title='${row[3][1]}'></i>`

          const room = row[3][2]
            ? `<a class='text-body' href='${row[3][2]}' target='_blank'>${tooltip_icon}</a>`
            : tooltip_icon

          return row[4][2]
          ? `${room}<a class='text-body' href='${row[4][2]}' target='_blank'>${display}</a>`
          : `${room}${display}`
        }
      }
    ]

    if(authenticated){
      columns.unshift({
        data: 6,
        name: "collected",
        title: "<i class='icon-active'></i>",
        orderable: false,
        searchable: false,
        width: "26px",
        render: collected => `<button class='toggle-item btn btn-link p-0'><i class='icon-${collected ? "" : "in"}active'></i></button>`
      })
    }

    // initialize Datatable
    const table = table_elm.DataTable({
      ajax: {
        url: '/api/items',
        dataSrc: ({ items, locations, displays, rooms }) => {
          for (let i = 0; i < items.length; i++) {

            // load room
            const room = rooms[items[i][3]]
            items[i][3] = [items[i][3], room[0], room[1]]

            // load display
            const display = displays[items[i][4]]
            items[i][4] = [items[i][4], display[0], display[1]]

            // load location
            const loc = locations[items[i][5]]
            items[i][5] = [items[i][5], loc ? loc[0] : null, loc ? loc[1] : null]
          }
          console.log(items[0])
          return items
        }
      },
      columns,
      dom:
        "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'d-flex justify-content-center'i>",
      deferRender: true,
      drawCallback: () => $('[data-toggle="tooltip"]').tooltip(),
      initComplete: () => $('#loader-wrapper').hide(),
      order: [[authenticated ? 2 : 1, 'asc']],
      rowId: 0,
      scrollY: 'calc(100vh - 185px)',
      scrollCollapse: true,
      scroller: true,
      stateSave: true
    })

    table_elm.on('click', '.toggle-item', function (){
      const id = $(this).parent().parent().attr('id')
      $.post(`/api/items/toggle/${id}`, collected => {
        table.cell($(this).parent()).data(collected).draw()
      })
    })
  }

  unmount() {
    super.unmount()
  }
}

