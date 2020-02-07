import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {

  mount() {
    super.mount()

    const table_elm = $('#item-table')
    const authenticated = table_elm.data('authenticated')
    const moderator = table_elm.data('moderator')

    // account for extra column when authenticated
    const columns = [
      { name: "id", searchable: false, orderable: false, visible: false },
      { name: "name", title:  "Name" },
      { name: "url", title: "URL", orderable: false },
    ]

    if(authenticated){
      columns.unshift({
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
      ajax: '/api/items',
      columns,
      dom:
        "<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6'f>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'d-flex justify-content-center'i>",
      deferRender: true,
      initComplete: () => $('#loader-wrapper').hide(),
      order: [[authenticated ? 2 : 1, 'asc']],
      rowId: authenticated ? 1 : 0,
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

